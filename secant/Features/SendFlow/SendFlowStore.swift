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
        case inProgress
        case success
        case failure
        case done
    }

    var addMemoState: Bool
    var isSendingTransaction = false
    var memoState: MultiLineTextFieldState
    var route: Route?
    var shieldedBalance = WalletBalance.zero
    var transactionAddressInputState: TransactionAddressTextFieldState
    var transactionAmountInputState: TransactionAmountTextFieldState

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

// MARK: - Action

enum SendFlowAction: Equatable {
    case addMemo(CheckCircleAction)
    case memo(MultiLineTextFieldAction)
    case onAppear
    case onDisappear
    case sendConfirmationPressed
    case sendTransactionResult(Result<TransactionState, NSError>)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case transactionAddressInput(TransactionAddressTextFieldAction)
    case transactionAmountInput(TransactionAmountTextFieldAction)
    case updateRoute(SendFlowState.Route?)
}

// MARK: - Environment

struct SendFlowEnvironment {
    let derivationTool: WrappedDerivationTool
    let mnemonic: WrappedMnemonic
    let numberFormatter: WrappedNumberFormatter
    let SDKSynchronizer: WrappedSDKSynchronizer
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

// MARK: - Reducer

extension SendFlowReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = SendFlowReducer.combine(
        [
            sendReducer,
            transactionAddressInputReducer,
            transactionAmountInputReducer,
            memoReducer,
            addMemoReducer
        ]
    )

    private static let sendReducer = SendFlowReducer { state, action, environment in
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
                let storedWallet = try environment.walletStorage.exportWallet()
                let seedBytes = try environment.mnemonic.toSeed(storedWallet.seedPhrase)
                guard let spendingKey = try environment.derivationTool.deriveSpendingKeys(seedBytes, 1).first else {
                    return Effect(value: .updateRoute(.failure))
                }

                state.isSendingTransaction = true

                let sendTransActionEffect = environment.SDKSynchronizer.sendTransaction(
                    with: spendingKey,
                    zatoshi: state.amount,
                    to: state.address,
                    memo: state.addMemoState ? state.memoState.text : nil,
                    from: 0
                )
                .receive(on: environment.scheduler)
                .map(SendFlowAction.sendTransactionResult)
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
            state.memoState.charLimit = environment.zcashSDKEnvironment.memoCharLimit
            return environment.SDKSynchronizer.stateChanged
                .map(SendFlowAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: SyncStatusUpdatesID(), cancelInFlight: true)
            
        case .onDisappear:
            return Effect.cancel(id: SyncStatusUpdatesID())
            
        case .synchronizerStateChanged(.synced):
            if let shieldedBalance = environment.SDKSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                state.shieldedBalance = shieldedBalance
                state.transactionAmountInputState.maxValue = shieldedBalance.total.amount
            }
            return .none
            
        case .synchronizerStateChanged(let synchronizerState):
            return .none

        case .memo:
            return .none
        }
    }

    private static let addMemoReducer: SendFlowReducer = CheckCircleReducer.default.pullback(
        state: \SendFlowState.addMemoState,
        action: /SendFlowAction.addMemo,
        environment: { _ in Void() }
    )

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
        environment: { environment in
            TransactionAmountTextFieldEnvironment(
                numberFormatter: environment.numberFormatter
            )
        }
    )

    private static let memoReducer: SendFlowReducer = MultiLineTextFieldReducer.default.pullback(
        state: \SendFlowState.memoState,
        action: /SendFlowAction.memo,
        environment: { _ in MultiLineTextFieldEnvironment() }
    )
}

// MARK: - Store

extension SendFlowStore {
    func addMemoStore() -> CheckCircleStore {
        self.scope(
            state: \.addMemoState,
            action: SendFlowAction.addMemo
        )
    }

    func memoStore() -> MultiLineTextFieldStore {
        self.scope(
            state: \.memoState,
            action: SendFlowAction.memo
        )
    }
}

// MARK: - ViewStore

extension SendFlowViewStore {
    var routeBinding: Binding<SendFlowState.Route?> {
        self.binding(
            get: \.route,
            send: SendFlowAction.updateRoute
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
            embed: { $0 ? SendFlowState.Route.confirmation : nil }
        )
    }

    var bindingForInProgress: Binding<Bool> {
        self.routeBinding.map(
            extract: {
                $0 == .inProgress ||
                $0 == .success ||
                $0 == .failure
            },
            embed: { $0 ? SendFlowState.Route.inProgress : SendFlowState.Route.confirmation }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .success },
            embed: { _ in SendFlowState.Route.success }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .failure },
            embed: { _ in SendFlowState.Route.failure }
        )
    }
}

// MARK: Placeholders

extension SendFlowState {
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
            reducer: .default,
            environment: SendFlowEnvironment(
                derivationTool: .live(),
                mnemonic: .live,
                numberFormatter: .live(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                walletStorage: .live(),
                zcashSDKEnvironment: .mainnet
            )
        )
    }
}
// #endif
