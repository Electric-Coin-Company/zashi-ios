//
//  SendFlowStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04/25/2022.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

typealias SendFlowReducer = Reducer<SendFlowState, SendFlowAction, SendFlowEnvironment>
typealias SendFlowStore = Store<SendFlowState, SendFlowAction>
typealias SendFlowViewStore = ViewStore<SendFlowState, SendFlowAction>

// MARK: - State

struct SendFlowState: Equatable {
    enum Route: Equatable {
        case confirmation
        case success
        case failure
        case done
    }

    var route: Route?
    
    var isSendingTransaction = false
    var memo = ""
    var totalBalance: Int64 = 0
    var transaction: SendFlowTransaction
    var transactionAddressInputState: TransactionAddressTextFieldState
    var transactionAmountInputState: TransactionAmountTextFieldState

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
    }
    
    var isInsufficientFunds: Bool {
        transactionAmountInputState.amount > transactionAmountInputState.maxValue
    }

    var totalCurrencyBalance: Int64 {
        (totalBalance.asHumanReadableZecBalance() * transactionAmountInputState.zecPrice).asZec()
    }
}

// MARK: - Action

enum SendFlowAction: Equatable {
    case onAppear
    case onDisappear
    case sendConfirmationPressed
    case sendTransactionResult(Result<TransactionState, NSError>)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case transactionAddressInput(TransactionAddressTextFieldAction)
    case transactionAmountInput(TransactionAmountTextFieldAction)
    case updateBalance(Int64)
    case updateMemo(String)
    case updateTransaction(SendFlowTransaction)
    case updateRoute(SendFlowState.Route?)
}

// MARK: - Environment

struct SendFlowEnvironment {
    let mnemonic: WrappedMnemonic
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WrappedWalletStorage
    let derivationTool: WrappedDerivationTool
    let SDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - Reducer

extension SendFlowReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = SendFlowReducer.combine(
        [
            sendReducer,
            transactionAddressInputReducer,
            transactionAmountInputReducer
        ]
    )
    .debug()

    private static let sendReducer = SendFlowReducer { state, action, environment in
        switch action {
        case let .updateTransaction(transaction):
            state.transaction = transaction
            return .none

        case .updateRoute(.failure):
            state.route = .failure
            state.isSendingTransaction = false
            return .none

        case .updateRoute(.confirmation):
            state.transaction.amount = state.transactionAmountInputState.amount
            state.transaction.toAddress = state.transactionAddressInputState.textFieldState.text
            return .none
            
        case let .updateRoute(route):
            state.route = route
            return .none
            
        case .sendConfirmationPressed:
            guard !state.isSendingTransaction else {
                return .none
            }

            do {
                let storedWallet = try environment.walletStorage.exportWallet()
                let seedBytes = try environment.mnemonic.toSeed(storedWallet.seedPhrase)
                guard let spendingKey = try environment.derivationTool.deriveSpendingKeys(seedBytes, 1).first else {
                    return Effect(value: .updateRoute(.failure))
                }
                
                state.isSendingTransaction = true
                
                return environment.SDKSynchronizer.sendTransaction(
                    with: spendingKey,
                    zatoshi: Int64(state.transaction.amount),
                    to: state.transaction.toAddress,
                    memo: state.transaction.memo,
                    from: 0
                )
                .receive(on: environment.scheduler)
                .map(SendFlowAction.sendTransactionResult)
                .eraseToEffect()
            } catch {
                return Effect(value: .updateRoute(.failure))
            }
            
        case .sendTransactionResult(let result):
            state.isSendingTransaction = false
            do {
                let transaction = try result.get()
                return Effect(value: .updateRoute(.success))
            } catch {
                return Effect(value: .updateRoute(.failure))
            }
            
        case .transactionAmountInput(let transactionInput):
            return .none

        case .transactionAddressInput(let transactionInput):
            return .none

        case .onAppear:
            return environment.SDKSynchronizer.stateChanged
                .map(SendFlowAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: SyncStatusUpdatesID(), cancelInFlight: true)
            
        case .onDisappear:
            return Effect.cancel(id: SyncStatusUpdatesID())
            
        case .synchronizerStateChanged(.synced):
            return environment.SDKSynchronizer.getShieldedBalance()
                .receive(on: environment.scheduler)
                .map({ $0.total })
                .map(SendFlowAction.updateBalance)
                .eraseToEffect()
            
        case .synchronizerStateChanged(let synchronizerState):
            return .none
            
        case .updateBalance(let balance):
            state.totalBalance = balance
            state.transactionAmountInputState.maxValue = balance
            return .none

        case .updateMemo(let memo):
            state.memo = memo
            return .none
        }
    }

    private static let transactionAddressInputReducer: SendFlowReducer = TransactionAddressTextFieldReducer.default.pullback(
        state: \SendFlowState.transactionAddressInputState,
        action: /SendFlowAction.transactionAddressInput,
        environment: { environment in
            TransactionAddressTextFieldEnvironment(
                derivationTool: environment.derivationTool
            )
        }
    )

    private static let transactionAmountInputReducer: SendFlowReducer = TransactionAmountTextFieldReducer.default.pullback(
        state: \SendFlowState.transactionAmountInputState,
        action: /SendFlowAction.transactionAmountInput,
        environment: { _ in TransactionAmountTextFieldEnvironment() }
    )
    
    static func `default`(whenDone: @escaping () -> Void) -> SendFlowReducer {
        SendFlowReducer { state, action, environment in
            switch action {
            case let .updateRoute(route) where route == .done:
                return Effect.fireAndForget(whenDone)
            default:
                return Self.default.run(&state, action, environment)
            }
        }
    }
}

// MARK: - ViewStore

extension SendFlowViewStore {
    var bindingForTransaction: Binding<SendFlowTransaction> {
        self.binding(
            get: \.transaction,
            send: SendFlowAction.updateTransaction
        )
    }

    var routeBinding: Binding<SendFlowState.Route?> {
        self.binding(
            get: \.route,
            send: SendFlowAction.updateRoute
        )
    }

    var bindingForConfirmation: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .confirmation || self.bindingForSuccess.wrappedValue || self.bindingForFailure.wrappedValue },
            embed: { $0 ? SendFlowState.Route.confirmation : nil }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .success || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendFlowState.Route.success : SendFlowState.Route.confirmation }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .failure || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendFlowState.Route.failure : SendFlowState.Route.confirmation }
        )
    }
    
    var bindingForDone: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .done },
            embed: { $0 ? SendFlowState.Route.done : SendFlowState.Route.confirmation }
        )
    }

    var bindingForMemo: Binding<String> {
        self.binding(
            get: \.memo,
            send: SendFlowAction.updateMemo
        )
    }
}

// MARK: Placeholders

extension SendFlowState {
    static var placeholder: Self {
        .init(
            route: nil,
            transaction: .placeholder,
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .amount
        )
    }

    static var emptyPlaceholder: Self {
        .init(
            route: nil,
            transaction: .init(
                amount: 0,
                memo: "",
                toAddress: ""
            ),
            transactionAddressInputState: .placeholder,
            transactionAmountInputState: .placeholder
        )
    }
}

// #if DEBUG // FIX: Issue #306 - Release build is broken
extension SendFlowStore {
    static var placeholder: SendFlowStore {
        return SendFlowStore(
            initialState: .init(
                route: nil,
                transaction: .placeholder,
                transactionAddressInputState: .placeholder,
                transactionAmountInputState: .placeholder
            ),
            reducer: .default,
            environment: SendFlowEnvironment(
                mnemonic: .live,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                walletStorage: .live(),
                derivationTool: .live(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }
}
// #endif
