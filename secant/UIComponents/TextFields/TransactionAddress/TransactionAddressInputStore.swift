//
//  TransactionAddressInputStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05/05/22.
//

import ComposableArchitecture
import SwiftUI

typealias TransactionAddressInputReducer = Reducer<
    TransactionAddressInputState,
    TransactionAddressInputAction,
    TransactionAddressInputEnvironment
>

typealias TransactionAddressInputStore = Store<TransactionAddressInputState, TransactionAddressInputAction>

struct TransactionAddressInputState: Equatable {
    var textFieldState: TextFieldState
    var isValidAddress = false
}

enum TransactionAddressInputAction: Equatable {
    case clearAddress
    case textField(TextFieldAction)
}

struct TransactionAddressInputEnvironment {
    let wrappedDerivationTool: WrappedDerivationTool
}

extension TransactionAddressInputReducer {
    static let `default` = TransactionAddressInputReducer.combine(
        [
            addressReducer,
            textFieldReducer
        ]
    )
    
    private static let addressReducer = TransactionAddressInputReducer { state, action, environment in
        switch action {
        case .clearAddress:
            state.textFieldState.text = ""
            return .none

        case .textField(.set(let address)):
            do {
                state.isValidAddress = try environment.wrappedDerivationTool.isValidZcashAddress(address)
            } catch {
                state.isValidAddress = false
            }
                
            return .none
        }
    }
    
    private static let textFieldReducer: TransactionAddressInputReducer = TextFieldReducer.default.pullback(
        state: \TransactionAddressInputState.textFieldState,
        action: /TransactionAddressInputAction.textField,
        environment: { _ in return .init() }
    )
}

extension TransactionAddressInputState {
    static let placeholder = TransactionAddressInputState(
        textFieldState: .placeholder
    )
}

extension TransactionAddressInputStore {
    static let placeholder = TransactionAddressInputStore(
        initialState: .placeholder,
        reducer: .default,
        environment: TransactionAddressInputEnvironment(
            wrappedDerivationTool: .live()
        )
    )
}
