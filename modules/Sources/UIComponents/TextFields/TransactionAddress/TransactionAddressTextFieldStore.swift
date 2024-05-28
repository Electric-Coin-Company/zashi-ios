//
//  TransactionAddressTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import DerivationTool
import ZcashSDKEnvironment
import FeedbackGenerator

public typealias TransactionAddressTextFieldStore = Store<TransactionAddressTextFieldReducer.State, TransactionAddressTextFieldReducer.Action>
public typealias TransactionAddressTextFieldViewStore = ViewStore<TransactionAddressTextFieldReducer.State, TransactionAddressTextFieldReducer.Action>

public struct TransactionAddressTextFieldReducer: Reducer {
    private enum Constants {
        static let delayBeforeHapticStart = UInt64(500_000_000)
        static let delayBetweenHaptics = UInt64(930_000_000)
    }

    public struct State: Equatable {
        public var doesButtonPulse: Bool = false
        public var isValidAddress = false
        public var isValidTransparentAddress = false
        public var textFieldState: TCATextFieldReducer.State
        
        public init(isValidAddress: Bool = false, isValidTransparentAddress: Bool = false, textFieldState: TCATextFieldReducer.State) {
            self.isValidAddress = isValidAddress
            self.isValidTransparentAddress = isValidTransparentAddress
            self.textFieldState = textFieldState
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case clearAddress
        case haptic
        case onAppear
        case onDisappear
        case scanQR
        case textField(TCATextFieldReducer.Action)
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.feedbackGenerator) var feedbackGenerator
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.doesButtonPulse {
                    return .run { send in
                        try? await Task.sleep(nanoseconds: Constants.delayBeforeHapticStart)
                        await send(.haptic)
                    }
                }
                return .none

            case .clearAddress:
                state.textFieldState.text = "".redacted
                return .none

            case .haptic:
                return .run { [state] send in
                    feedbackGenerator.generateSuccessFeedback()
                    try? await Task.sleep(nanoseconds: Constants.delayBetweenHaptics)
                    if state.doesButtonPulse {
                        await send(.haptic)
                    }
                }
            
            case .scanQR, .onDisappear:
                state.doesButtonPulse = false
                return .none

            case .textField(.set(let address)):
                let network = zcashSDKEnvironment.network.networkType
                state.isValidAddress = derivationTool.isZcashAddress(address.data, network)
                state.isValidTransparentAddress = derivationTool.isTransparentAddress(address.data, network)
                return .none
            }
        }
        
        Scope(state: \.textFieldState, action: /Action.textField) {
            TCATextFieldReducer()
        }
    }
}

// MARK: - Placeholders

extension TransactionAddressTextFieldReducer.State {
    public static let initial = TransactionAddressTextFieldReducer.State(
        textFieldState: .initial
    )
}

extension TransactionAddressTextFieldStore {
    public static let placeholder = TransactionAddressTextFieldStore(
        initialState: .initial
    ) {
        TransactionAddressTextFieldReducer()
    }
}
