import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    enum Route: Equatable {
        case history
        case send
    }
    var transactionHistoryState: TransactionHistoryState
    var route: Route?
}

enum HomeAction: Equatable {
    case updateRoute(HomeState.Route?)
    case transactionHistory(TransactionHistoryAction)
}

// MARK: - HomeReducer

typealias HomeReducer = Reducer<HomeState, HomeAction, Void>

extension HomeReducer {
    static let `default` = HomeReducer { state, action, _ in
        switch action {
        case let .updateRoute(route):
            state.route = route
            return .none
        case let .transactionHistory(transactionHistoryAction):
            return TransactionHistoryReducer
                .default
                .run(&state.transactionHistoryState, transactionHistoryAction, ())
                .map(HomeAction.transactionHistory)
        }
    }
}

// MARK: - HomeStore

typealias HomeStore = Store<HomeState, HomeAction>

extension HomeStore {
    func historyStore() -> TransactionHistoryStore {
        self.scope(
            state: \.transactionHistoryState,
            action: HomeAction.transactionHistory
        )
    }
}

// MARK: - HomeViewStore

typealias HomeViewStore = ViewStore<HomeState, HomeAction>

extension HomeViewStore {
    func historyToggleString() -> String {
        let hideShowString = isHistoryActive ? "HIDE" : "SHOW"
        let selectedString = selectedTranactionID.map { "selected id: \($0)" } ?? "NONE selected"
        let parts = [hideShowString, "History", selectedString]
        return parts.joined(separator: " ")
    }

    func toggleShowingHistory() {
        send(.updateRoute(isHistoryActive ? nil : .history))
    }

    func toggleSelectedTransaction() {
        let isAlreadySelected = (self.selectedTranactionID != nil)
        let transcation = self.transactionHistoryState.transactions[5]
        let newRoute = isAlreadySelected ? nil : TransactionHistoryState.Route.showTransaction(transcation)
        send(.transactionHistory(.setRoute(newRoute)))
    }

    var isHistoryActive: Bool {
        self.route == .history
    }

    var selectedTranactionID: Int? {
        self.transactionHistoryState
            .route
            .flatMap(/TransactionHistoryState.Route.showTransaction)
            .map(\.id)
    }

    var showHistoryBinding: Binding<Bool> {
        self.binding(
            get: { $0.route == .history },
            send: { isActive in
                return .updateRoute(isActive ? .history : nil)
            }
        )
    }

    var showSendBinding: Binding<Bool> {
        self.binding(
            get: { $0.route == .send },
            send: { isActive in
                return .updateRoute(isActive ? .send : nil)
            }
        )
    }
}
