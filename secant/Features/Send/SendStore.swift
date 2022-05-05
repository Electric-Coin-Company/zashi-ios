import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

struct Transaction: Equatable {
    var amount: Int64
    var memo: String
    var toAddress: String
}

extension Transaction {
    static var placeholder: Self {
        .init(
            amount: 0,
            memo: "",
            toAddress: ""
        )
    }
}

struct SendState: Equatable {
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
    var transaction: Transaction
    var transactionAddressInputState: TransactionAddressInputState
    var transactionAmountInputState: TransactionAmountInputState

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

enum SendAction: Equatable {
    case onAppear
    case onDisappear
    case sendConfirmationPressed
    case sendTransactionResult(Result<TransactionState, NSError>)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case transactionAddressInput(TransactionAddressInputAction)
    case transactionAmountInput(TransactionAmountInputAction)
    case updateBalance(Int64)
    case updateMemo(String)
    case updateTransaction(Transaction)
    case updateRoute(SendState.Route?)
}

struct SendEnvironment {
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WalletStorageInteractor
    let wrappedDerivationTool: WrappedDerivationTool
    let wrappedSDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - SendReducer

private struct ListenerId: Hashable {}

typealias SendReducer = Reducer<SendState, SendAction, SendEnvironment>

extension SendReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = SendReducer.combine(
        [
            sendReducer,
            transactionAddressInputReducer,
            transactionAmountInputReducer
        ]
    )
    .debug()

    private static let sendReducer = SendReducer { state, action, environment in
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
                let seedBytes = try environment.mnemonicSeedPhraseProvider.toSeed(storedWallet.seedPhrase)
                guard let spendingKey = try environment.wrappedDerivationTool.deriveSpendingKeys(seedBytes, 1).first else {
                    return Effect(value: .updateRoute(.failure))
                }
                
                state.isSendingTransaction = true
                
                return environment.wrappedSDKSynchronizer.sendTransaction(
                    with: spendingKey,
                    zatoshi: Int64(state.transaction.amount),
                    to: state.transaction.toAddress,
                    memo: state.transaction.memo,
                    from: 0
                )
                .receive(on: environment.scheduler)
                .map(SendAction.sendTransactionResult)
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
            return environment.wrappedSDKSynchronizer.stateChanged
                .map(SendAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: ListenerId(), cancelInFlight: true)
            
        case .onDisappear:
            return Effect.cancel(id: ListenerId())
            
        case .synchronizerStateChanged(.synced):
            return environment.wrappedSDKSynchronizer.getShieldedBalance()
                .receive(on: environment.scheduler)
                .map({ $0.total })
                .map(SendAction.updateBalance)
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

    private static let transactionAddressInputReducer: SendReducer = TransactionAddressInputReducer.default.pullback(
        state: \SendState.transactionAddressInputState,
        action: /SendAction.transactionAddressInput,
        environment: { environment in
            TransactionAddressInputEnvironment(
                wrappedDerivationTool: environment.wrappedDerivationTool
            )
        }
    )

    private static let transactionAmountInputReducer: SendReducer = TransactionAmountInputReducer.default.pullback(
        state: \SendState.transactionAmountInputState,
        action: /SendAction.transactionAmountInput,
        environment: { _ in TransactionAmountInputEnvironment() }
    )
    
    static func `default`(whenDone: @escaping () -> Void) -> SendReducer {
        SendReducer { state, action, environment in
            switch action {
            case let .updateRoute(route) where route == .done:
                return Effect.fireAndForget(whenDone)
            default:
                return Self.default.run(&state, action, environment)
            }
        }
    }
}

// MARK: - SendStore

typealias SendStore = Store<SendState, SendAction>

// MARK: - SendViewStore

typealias SendViewStore = ViewStore<SendState, SendAction>

extension SendViewStore {
    var bindingForTransaction: Binding<Transaction> {
        self.binding(
            get: \.transaction,
            send: SendAction.updateTransaction
        )
    }

    var routeBinding: Binding<SendState.Route?> {
        self.binding(
            get: \.route,
            send: SendAction.updateRoute
        )
    }

    var bindingForConfirmation: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .confirmation || self.bindingForSuccess.wrappedValue || self.bindingForFailure.wrappedValue },
            embed: { $0 ? SendState.Route.confirmation : nil }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .success || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendState.Route.success : SendState.Route.confirmation }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .failure || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendState.Route.failure : SendState.Route.confirmation }
        )
    }
    
    var bindingForDone: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .done },
            embed: { $0 ? SendState.Route.done : SendState.Route.confirmation }
        )
    }

    var bindingForMemo: Binding<String> {
        self.binding(
            get: \.memo,
            send: SendAction.updateMemo
        )
    }
}

// MARK: PlaceHolders

extension SendState {
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
