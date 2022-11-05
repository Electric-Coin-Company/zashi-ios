//
//  TransactionAddressTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import ComposableArchitecture
import SwiftUI

typealias TransactionAddressTextFieldReducer = Reducer<
    TransactionAddressTextFieldState,
    TransactionAddressTextFieldAction,
    TransactionAddressTextFieldEnvironment
>

typealias TransactionAddressTextFieldStore = Store<TransactionAddressTextFieldState, TransactionAddressTextFieldAction>

typealias AnyTCATextFieldReducerAddress = AnyReducer<TCATextFieldReducer.State, TCATextFieldReducer.Action, TransactionAddressTextFieldEnvironment>

struct TransactionAddressTextFieldState: Equatable {
    var isValidAddress = false
    var textFieldState: TCATextFieldReducer.State
}

enum TransactionAddressTextFieldAction: Equatable {
    case clearAddress
    case textField(TCATextFieldReducer.Action)
}

struct TransactionAddressTextFieldEnvironment {
    let derivationTool: WrappedDerivationTool
}

extension TransactionAddressTextFieldReducer {
    static let `default` = TransactionAddressTextFieldReducer.combine(
        [
            addressReducer,
            textFieldReducer
        ]
    )
    
    private static let addressReducer = TransactionAddressTextFieldReducer { state, action, environment in
        switch action {
        case .clearAddress:
            state.textFieldState.text = ""
            return .none

        case .textField(.set(let address)):
            do {
                state.isValidAddress = try environment.derivationTool.isValidZcashAddress(address)
            } catch {
                state.isValidAddress = false
            }
                
            return .none
        }
    }
    
    private static let textFieldReducer: TransactionAddressTextFieldReducer = AnyTCATextFieldReducerAddress { _ in
        TCATextFieldReducer()
    }
    .pullback(
        state: \TransactionAddressTextFieldState.textFieldState,
        action: /TransactionAddressTextFieldAction.textField,
        environment: { $0 }
    )
}

extension TransactionAddressTextFieldState {
    static let placeholder = TransactionAddressTextFieldState(
        textFieldState: .placeholder
    )
}

extension TransactionAddressTextFieldStore {
    static let placeholder = TransactionAddressTextFieldStore(
        initialState: .placeholder,
        reducer: .default,
        environment: TransactionAddressTextFieldEnvironment(
            derivationTool: .live()
        )
    )
}
