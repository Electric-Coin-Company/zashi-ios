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

public typealias TransactionAddressTextFieldStore = Store<TransactionAddressTextFieldReducer.State, TransactionAddressTextFieldReducer.Action>

public struct TransactionAddressTextFieldReducer: Reducer {
    public struct State: Equatable {
        public var isValidAddress = false
        public var isValidTransparentAddress = false
        public var textFieldState: TCATextFieldReducer.State
        
        public init(isValidAddress: Bool = false, isValidTransparentAddress: Bool = false, textFieldState: TCATextFieldReducer.State) {
            self.isValidAddress = isValidAddress
            self.isValidTransparentAddress = isValidTransparentAddress
            self.textFieldState = textFieldState
        }
    }

    public enum Action: Equatable {
        case clearAddress
        case scanQR
        case textField(TCATextFieldReducer.Action)
    }
    
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .clearAddress:
                state.textFieldState.text = "".redacted
                return .none
            
            case .scanQR:
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
