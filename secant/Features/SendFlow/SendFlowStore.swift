//
//  SendFlowStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

typealias SendFlowStore = Store<SendFlowReducer.State, SendFlowReducer.Action>
typealias SendFlowViewStore = ViewStore<SendFlowReducer.State, SendFlowReducer.Action>

struct SendFlowReducer: ReducerProtocol {
    private enum SyncStatusUpdatesID {}

    struct State: Equatable {
        enum Route: Equatable {
            case confirmation
            case inProgress
            case success
            case failure
            case done
        }

        var addMemoState: Bool
        var isSendingTransaction = false
        var memoState: MultiLineTextFieldReducer.State
        var route: Route?
        var shieldedBalance = WalletBalance.zero
        var transactionAddressInputState: TransactionAddressTextFieldReducer.State
        var transactionAmountInputState: TransactionAmountTextFieldReducer.State

        var address: String {
            get { transactionAddressInputState.textFieldState.text }
            set { transactionAddressInputState.textFieldState.text = newValue }
        }

        var amount: Zatoshi {
            get { Zatoshi(transactionAmountInputState.amount) }
            set {
                transactionAmountInputState.amount = newValue.amount
                transactionAmountInputState.textFieldState.text = newValue.amount == 0 ?
                "" :
                newValue.decimalString()
            }
        }

        var isInvalidAddressFormat: Bool {
            !transactionAddressInputState.isValidAddress
            && !transactionAddressInputState.textFieldState.text.isEmpty
        }

        var isInvalidAmountFormat: Bool {
            !transactionAmountInputState.textFieldState.valid
            && !transactionAmountInputState.textFieldState.text.isEmpty
        }
        
        var isValidForm: Bool {
            transactionAmountInputState.amount > 0
            && transactionAddressInputState.isValidAddress
            && !isInsufficientFunds
            && memoState.isValid
        }
        
        var isInsufficientFunds: Bool {
            transactionAmountInputState.amount > transactionAmountInputState.maxValue
        }

        var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.total.decimalValue.decimalValue * transactionAmountInputState.zecPrice)
        }
    }

    enum Action: Equatable {
        case addMemo(CheckCircleReducer.Action)
        case memo(MultiLineTextFieldReducer.Action)
        case onAppear
        case onDisappear
        case sendConfirmationPressed
        case sendTransactionResult(Result<TransactionState, NSError>)
        case synchronizerStateChanged(WrappedSDKSynchronizerState)
        case transactionAddressInput(TransactionAddressTextFieldReducer.Action)
        case transactionAmountInput(TransactionAmountTextFieldReducer.Action)
        case updateRoute(SendFlowReducer.State.Route?)
    }
    
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.addMemoState, action: /Action.addMemo) {
            CheckCircleReducer()
        }

        Scope(state: \.memoState, action: /Action.memo) {
            MultiLineTextFieldReducer()
        }

        Scope(state: \.transactionAddressInputState, action: /Action.transactionAddressInput) {
            TransactionAddressTextFieldReducer()
        }

        Scope(state: \.transactionAmountInputState, action: /Action.transactionAmountInput) {
            TransactionAmountTextFieldReducer()
        }

        Reduce { state, action in
            switch action {
            case .addMemo:
                return .none

            case .updateRoute(.done):
                state.route = nil
                state.memoState.text = ""
                state.transactionAmountInputState.textFieldState.text = ""
                state.transactionAmountInputState.amount = 0
                state.transactionAddressInputState.textFieldState.text = ""
                return .none

            case .updateRoute(.failure):
                state.route = .failure
                state.isSendingTransaction = false
                return .none

            case .updateRoute(.confirmation):
                state.amount = Zatoshi(state.transactionAmountInputState.amount)
                state.address = state.transactionAddressInputState.textFieldState.text
                state.route = .confirmation
                return .none
                
            case let .updateRoute(route):
                state.route = route
                return .none
                
            case .sendConfirmationPressed:
                guard !state.isSendingTransaction else {
                    return .none
                }

                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase)
                    guard let spendingKey = try derivationTool.deriveSpendingKeys(seedBytes, 1).first else {
                        return Effect(value: .updateRoute(.failure))
                    }

                    state.isSendingTransaction = true

                    let sendTransActionEffect = sdkSynchronizer.sendTransaction(
                        with: spendingKey,
                        zatoshi: state.amount,
                        to: state.address,
                        memo: state.addMemoState ? state.memoState.text : nil,
                        from: 0
                    )
                    .receive(on: mainQueue)
                    .map(SendFlowReducer.Action.sendTransactionResult)
                    .eraseToEffect()

                    return .concatenate(
                        Effect(value: .updateRoute(.inProgress)),
                        sendTransActionEffect
                    )
                } catch {
                    return Effect(value: .updateRoute(.failure))
                }
                
            case .sendTransactionResult(let result):
                state.isSendingTransaction = false
                do {
                    _ = try result.get()
                    return Effect(value: .updateRoute(.success))
                } catch {
                    return Effect(value: .updateRoute(.failure))
                }
                
            case .transactionAmountInput:
                return .none

            case .transactionAddressInput:
                return .none

            case .onAppear:
                state.memoState.charLimit = zcashSDKEnvironment.memoCharLimit
                return sdkSynchronizer.stateChanged
                    .map(SendFlowReducer.Action.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: SyncStatusUpdatesID.self, cancelInFlight: true)
                
            case .onDisappear:
                return Effect.cancel(id: SyncStatusUpdatesID.self)
                
            case .synchronizerStateChanged(.synced):
                if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                    state.shieldedBalance = shieldedBalance
                    state.transactionAmountInputState.maxValue = shieldedBalance.total.amount
                }
                return .none
                
            case .synchronizerStateChanged:
                return .none

            case .memo:
                return .none
            }
        }
    }
}

// MARK: - Store

extension SendFlowStore {
    func addMemoStore() -> CheckCircleStore {
        self.scope(
            state: \.addMemoState,
            action: SendFlowReducer.Action.addMemo
        )
    }

    func memoStore() -> MultiLineTextFieldStore {
        self.scope(
            state: \.memoState,
            action: SendFlowReducer.Action.memo
        )
    }
}

// MARK: - ViewStore

extension SendFlowViewStore {
    var routeBinding: Binding<SendFlowReducer.State.Route?> {
        self.binding(
            get: \.route,
            send: SendFlowReducer.Action.updateRoute
        )
    }

    var bindingForConfirmation: Binding<Bool> {
        self.routeBinding.map(
            extract: {
                $0 == .confirmation ||
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowReducer.State.Route.confirmation : nil }
        )
    }

    var bindingForInProgress: Binding<Bool> {
        self.routeBinding.map(
            extract: {
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowReducer.State.Route.inProgress : SendFlowReducer.State.Route.confirmation }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .success },
            embed: { _ in SendFlowReducer.State.Route.success }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .failure },
            embed: { _ in SendFlowReducer.State.Route.failure }
        )
    }
}

// MARK: Placeholders

extension SendFlowReducer.State {
    static var placeholder: Self {
        .init(
            addMemoState: true,
            memoState: .placeholder,
            route: nil,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .amount
        )
    }

    static var emptyPlaceholder: Self {
        .init(
            addMemoState: true,
            memoState: .placeholder,
            route: nil,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .placeholder
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendFlowStore {
    static var placeholder: SendFlowStore {
        return SendFlowStore(
            initialState: .emptyPlaceholder,
            reducer: SendFlowReducer()
        )
    }
}
// #endif
