//
//  TransactionAddressTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

typealias TransactionAddressTextFieldStore = Store<TransactionAddressTextFieldReducer.State, TransactionAddressTextFieldReducer.Action>

struct TransactionAddressTextFieldReducer: ReducerProtocol {
    struct State: Equatable {
        var isValidAddress = false
        var isValidTransparentAddress = false
        var textFieldState: TCATextFieldReducer.State
    }

    enum Action: Equatable {
        case clearAddress
        case scanQR
        case textField(TCATextFieldReducer.Action)
    }
    
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .clearAddress:
                state.textFieldState.text = "".redacted
                return .none
            
            case .scanQR:
                return .none

            case .textField(.set(let address)):
                state.isValidAddress = derivationTool.isZcashAddress(address.data, TargetConstants.zcashNetwork.networkType)
                state.isValidTransparentAddress = derivationTool.isTransparentAddress(address.data, TargetConstants.zcashNetwork.networkType)
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
    static let placeholder = TransactionAddressTextFieldReducer.State(
        textFieldState: .placeholder
    )
}

extension TransactionAddressTextFieldStore {
    static let placeholder = TransactionAddressTextFieldStore(
        initialState: .placeholder,
        reducer: TransactionAddressTextFieldReducer()
    )
}
