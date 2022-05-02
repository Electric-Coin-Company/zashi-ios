import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

struct Transaction: Equatable {
    var amount: Int64
    var memo: String
    var toAddress: String
    
    var amountString: String {
        get { amount == 0 ? "" : String(format: "%.7f", amount.asHumanReadableZecBalance()) }
        set { amount = Int64((newValue as NSString).doubleValue * 100_000_000) }
    }
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
        case showConfirmation
        case showSent
        case success
        case failure
        case done
    }

    var route: Route?
    
    var isSendingTransaction = false
    var transaction: Transaction
}

enum SendAction: Equatable {
    case sendConfirmationPressed
    case sendTransactionResult(Result<TransactionState, NSError>)
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

typealias SendReducer = Reducer<SendState, SendAction, SendEnvironment>

extension SendReducer {
    private struct SyncStatusUpdatesID: Hashable {}

    static let `default` = Reducer<SendState, SendAction, SendEnvironment> { state, action, environment in
        switch action {
        case let .updateTransaction(transaction):
            state.transaction = transaction
            return .none

        case .updateRoute(.failure):
            state.route = .failure
            state.isSendingTransaction = false
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
        }
    }
    
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
            extract: { $0 == .showConfirmation || self.bindingForSuccess.wrappedValue || self.bindingForFailure.wrappedValue },
            embed: { $0 ? SendState.Route.showConfirmation : nil }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .success || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendState.Route.success : SendState.Route.showConfirmation }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .failure || self.bindingForDone.wrappedValue },
            embed: { $0 ? SendState.Route.failure : SendState.Route.showConfirmation }
        )
    }
    
    var bindingForDone: Binding<Bool> {
        self.routeBinding.map(
            extract: { $0 == .done },
            embed: { $0 ? SendState.Route.done : SendState.Route.showConfirmation }
        )
    }
}

// MARK: PlaceHolders

extension SendState {
    static var placeholder: Self {
        .init(route: nil, transaction: .placeholder)
    }

    static var emptyPlaceholder: Self {
        .init(
            route: nil,
            transaction: .init(
                amount: 0,
                memo: "",
                toAddress: ""
            )
        )
    }
}
