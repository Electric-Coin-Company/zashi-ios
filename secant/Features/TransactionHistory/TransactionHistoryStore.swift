import ComposableArchitecture
import SwiftUI

struct Transaction: Identifiable, Equatable, Hashable {
    var id: Int
    var amount: UInt
    var memo: String
    var toAddress: String
    var fromAddress: String
}

struct TransactionHistoryState: Equatable {
    enum Route: Equatable {
        case showTransaction(Transaction)
    }

    var transactions: IdentifiedArrayOf<Transaction>
    var route: Route?
}

enum TransactionHistoryAction: Equatable {
    case setRoute(TransactionHistoryState.Route?)
}

// MARK: - TransactionHistoryReducer

typealias TransactionHistoryReducer = Reducer<TransactionHistoryState, TransactionHistoryAction, Void>

extension TransactionHistoryReducer {
    static let `default` = TransactionHistoryReducer { state, action, _ in
        switch action {
        case let .setRoute(route):
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

    func bindingForSelectingTransaction(_ transaction: Transaction) -> Binding<Bool> {
        self.binding(
            get: { $0.route.map(/TransactionHistoryState.Route.showTransaction) == transaction },
            send: { isActive in
                TransactionHistoryAction.setRoute( isActive ? TransactionHistoryState.Route.showTransaction(transaction) : nil)
            }
        )
    }
}
