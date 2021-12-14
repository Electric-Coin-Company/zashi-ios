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

// MARK: PlaceHolders

extension Transaction {
    static var placeholder: Self {
        .init(
            id: 2,
            amount: 123,
            memo: "defaultMemo",
            toAddress: "ToAddress",
            fromAddress: "FromAddress"
        )
    }
}

extension TransactionHistoryState {
    static var placeHolder: Self {
        .init(transactions: .placeholder, route: nil)
    }
}

extension TransactionHistoryStore {
    static var placeholder: Store<TransactionHistoryState, TransactionHistoryAction> {
        return Store(
            initialState: .placeHolder,
            reducer: .default,
            environment: ()
        )
    }

    static var demoWithSelectedTransaction: Store<TransactionHistoryState, TransactionHistoryAction> {
        let transactions = IdentifiedArrayOf<Transaction>.placeholder
        return Store(
            initialState: TransactionHistoryState(
                transactions: transactions,
                route: .showTransaction(transactions[3])
            ),
            reducer: .default.debug(),
            environment: ()
        )
    }
}

extension IdentifiedArrayOf where Element == Transaction {
    static var placeholder: IdentifiedArrayOf<Transaction> {
        return .init(
            uniqueElements: (0..<10).map {
                Transaction(
                    id: $0,
                    amount: 25,
                    memo: "defaultMemo",
                    toAddress: "ToAddress",
                    fromAddress: "FromAddress"
                )
            }
        )
    }
}
