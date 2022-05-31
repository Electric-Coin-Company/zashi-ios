import ComposableArchitecture
import SwiftUI

typealias TransactionHistoryFlowReducer = Reducer<TransactionHistoryFlowState, TransactionHistoryFlowAction, TransactionHistoryFlowEnvironment>
typealias TransactionHistoryFlowStore = Store<TransactionHistoryFlowState, TransactionHistoryFlowAction>
typealias TransactionHistoryFlowViewStore = ViewStore<TransactionHistoryFlowState, TransactionHistoryFlowAction>

// MARK: - State

struct TransactionHistoryFlowState: Equatable {
    enum Route: Equatable {
        case latest
        case all
        case showTransaction(TransactionState)
    }

    var route: Route?

    var isScrollable = false
    var transactions: IdentifiedArrayOf<TransactionState>
}

// MARK: - Action

enum TransactionHistoryFlowAction: Equatable {
    case onAppear
    case onDisappear
    case updateRoute(TransactionHistoryFlowState.Route?)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case updateTransactions([TransactionState])
}

// MARK: - Environment

struct TransactionHistoryFlowEnvironment {
    let scheduler: AnySchedulerOf<DispatchQueue>
    let SDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - Reducer

extension TransactionHistoryFlowReducer {
    private struct CancelId: Hashable {}
    
    static let `default` = TransactionHistoryFlowReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.SDKSynchronizer.stateChanged
                .map(TransactionHistoryFlowAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .synchronizerStateChanged(.synced):
            return environment.SDKSynchronizer.getAllTransactions()
                .receive(on: environment.scheduler)
                .map(TransactionHistoryFlowAction.updateTransactions)
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

// MARK: - ViewStore

extension TransactionHistoryFlowViewStore {
    private typealias Route = TransactionHistoryFlowState.Route

    func bindingForSelectingTransaction(_ transaction: TransactionState) -> Binding<Bool> {
        self.binding(
            get: { $0.route.map(/TransactionHistoryFlowState.Route.showTransaction) == transaction },
            send: { isActive in
                TransactionHistoryFlowAction.updateRoute( isActive ? TransactionHistoryFlowState.Route.showTransaction(transaction) : nil)
            }
        )
    }
}

// MARK: Placeholders

extension TransactionState {
    static var placeholder: Self {
        .init(
            date: Date.init(timeIntervalSince1970: 1234567),
            id: "2",
            status: .paid(success: true),
            subtitle: "",
            zecAmount: Zatoshi(amount: 25)
        )
    }
}

extension TransactionHistoryFlowState {
    static var placeHolder: Self {
        .init(transactions: .placeholder)
    }

    static var emptyPlaceHolder: Self {
        .init(transactions: [])
    }
}

extension TransactionHistoryFlowStore {
    static var placeholder: Store<TransactionHistoryFlowState, TransactionHistoryFlowAction> {
        return Store(
            initialState: .placeHolder,
            reducer: .default,
            environment: TransactionHistoryFlowEnvironment(
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }

    static var demoWithSelectedTransaction: Store<TransactionHistoryFlowState, TransactionHistoryFlowAction> {
        let transactions = IdentifiedArrayOf<TransactionState>.placeholder
        return Store(
            initialState: TransactionHistoryFlowState(
                route: .showTransaction(transactions[3]),
                transactions: transactions
            ),
            reducer: .default.debug(),
            environment: TransactionHistoryFlowEnvironment(
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer()
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
                    zecAmount: Zatoshi(amount: 25)
                )
            }
        )
    }
}
