import ComposableArchitecture
import SwiftUI

extension Date {
    func asHumanReadable() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: self)
    }
}

struct TransactionHistoryState: Equatable {
    enum Route: Equatable {
        case latest
        case all
        case showTransaction(TransactionState)
    }

    var route: Route?

    var isScrollable = false
    var transactions: IdentifiedArrayOf<TransactionState>
}

enum TransactionHistoryAction: Equatable {
    case onAppear
    case onDisappear
    case updateRoute(TransactionHistoryState.Route?)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case updateTransactions([TransactionState])
}

struct TransactionHistoryEnvironment {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let wrappedSDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - TransactionHistoryReducer

private struct ListenerId: Hashable {}

typealias TransactionHistoryReducer = Reducer<TransactionHistoryState, TransactionHistoryAction, TransactionHistoryEnvironment>

extension TransactionHistoryReducer {
    static let `default` = TransactionHistoryReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.wrappedSDKSynchronizer.stateChanged
                .map(TransactionHistoryAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: ListenerId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: ListenerId())

        case .synchronizerStateChanged(.synced):
            return environment.wrappedSDKSynchronizer.getAllTransactions()
                .receive(on: environment.scheduler)
                .map(TransactionHistoryAction.updateTransactions)
                .eraseToEffect()
            
        case .synchronizerStateChanged(let synchronizerState):
            return .none
            
        case .updateTransactions(let transactions):
            let sortedTransactions = transactions
                .sorted(by: { lhs, rhs in
                    lhs.date > rhs.date
                })
            state.transactions = IdentifiedArrayOf(uniqueElements: sortedTransactions)
            return .none

        case let .updateRoute(route):
            state.route = route
            return .none
        }
    }
}

// MARK: - TransactionHistoryStore

typealias TransactionHistoryStore = Store<TransactionHistoryState, TransactionHistoryAction>

// MARK: - TransactionHistoryViewStore

typealias TransactionHistoryViewStore = ViewStore<TransactionHistoryState, TransactionHistoryAction>

extension TransactionHistoryViewStore {
    private typealias Route = TransactionHistoryState.Route

    func bindingForSelectingTransaction(_ transaction: TransactionState) -> Binding<Bool> {
        self.binding(
            get: { $0.route.map(/TransactionHistoryState.Route.showTransaction) == transaction },
            send: { isActive in
                TransactionHistoryAction.updateRoute( isActive ? TransactionHistoryState.Route.showTransaction(transaction) : nil)
            }
        )
    }
}

// MARK: PlaceHolders

extension TransactionState {
    static var placeholder: Self {
        .init(
            date: Date.init(timeIntervalSince1970: 1234567),
            id: "2",
            status: .paid(success: true),
            subtitle: "",
            zecAmount: 25
        )
    }
}

extension TransactionHistoryState {
    static var placeHolder: Self {
        .init(transactions: .placeholder)
    }

    static var emptyPlaceHolder: Self {
        .init(transactions: [])
    }
}

extension TransactionHistoryStore {
    static var placeholder: Store<TransactionHistoryState, TransactionHistoryAction> {
        return Store(
            initialState: .placeHolder,
            reducer: .default,
            environment: TransactionHistoryEnvironment(
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }

    static var demoWithSelectedTransaction: Store<TransactionHistoryState, TransactionHistoryAction> {
        let transactions = IdentifiedArrayOf<TransactionState>.placeholder
        return Store(
            initialState: TransactionHistoryState(
                route: .showTransaction(transactions[3]),
                transactions: transactions
            ),
            reducer: .default.debug(),
            environment: TransactionHistoryEnvironment(
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }
}

extension IdentifiedArrayOf where Element == TransactionState {
    static var placeholder: IdentifiedArrayOf<TransactionState> {
        return .init(
            uniqueElements: (0..<30).map {
                TransactionState(
                    date: Date.init(timeIntervalSince1970: 1234567),
                    id: String($0),
                    status: .paid(success: true),
                    subtitle: "",
                    zecAmount: 25
                )
            }
        )
    }
}
