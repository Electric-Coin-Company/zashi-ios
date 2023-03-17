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
                do {
                    state.isValidAddress = try derivationTool.isValidZcashAddress(address.data)
                } catch {
                    state.isValidAddress = false
                }
                do {
                    if case .transparent = try Recipient(address.data, network: zcashSDKEnvironment.network.networkType) {
                        state.isValidTransparentAddress = true
                    } else {
                        state.isValidTransparentAddress = false
                    }
                    state.isValidTransparentAddress = true
                } catch {
                    state.isValidTransparentAddress = false
                }

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
