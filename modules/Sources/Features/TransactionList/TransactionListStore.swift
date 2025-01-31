import ComposableArchitecture
import SwiftUI
import Models

@Reducer
public struct TransactionList {
    public enum Constants {
        public static let homePageTransactionsCount = 5
    }

    @ObservableState
    public struct State: Equatable {
        public var CancelId = UUID()

        public var isInvalidated = true
        public var latestTransactionId = ""
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        public var transactionListHomePage: IdentifiedArrayOf<TransactionState> = []

        public init() { }
    }

    public enum Action: Equatable {
        case onAppear
        case transactionsUpdated
        case transactionTapped(String)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .publisher {
                    state.$transactions.publisher
                        .map { _ in
                            TransactionList.Action.transactionsUpdated
                        }
                }
                .cancellable(id: state.CancelId, cancelInFlight: true)
 
            case .transactionsUpdated:
                state.isInvalidated = false
                state.transactionListHomePage = IdentifiedArrayOf(uniqueElements: state.transactions.prefix(Constants.homePageTransactionsCount))
                state.latestTransactionId = state.transactionListHomePage.last?.id ?? ""
                return .none

            case .transactionTapped:
                return .none
            }
        }
    }
}
