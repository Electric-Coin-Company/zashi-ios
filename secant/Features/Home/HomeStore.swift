import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    enum Route: Equatable, CaseIterable {
        case history
        case send
        case recoveryPhraseDisplay
        case profile
        case scan
        case request
    }
    var transactionHistoryState: TransactionHistoryState
    var profileState: ProfileState
    var route: Route?
}

enum HomeAction: Equatable {
    case updateRoute(HomeState.Route?)
    case transactionHistory(TransactionHistoryAction)
    case profile(ProfileAction)
    case reset
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
        case let .profile(profileAction):
            return ProfileReducer
                .default
                .pullback(
                    state: \.profileState,
                    action: /HomeAction.profile,
                    environment: { _ in
                        return ProfileEnvironment()
                    })
                .run(&state, action, ())
        case .reset:
            return .none
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

    func profileStore() -> ProfileStore {
        self.scope(
            state: \.profileState,
            action: HomeAction.profile
        )
    }
}

// MARK: - HomeViewStore

typealias HomeViewStore = ViewStore<HomeState, HomeAction>

extension HomeViewStore {
    func toggleSelectedTransaction() {
        let isAlreadySelected = (self.selectedTranactionID != nil)
        let transcation = self.transactionHistoryState.transactions[5]
        let newRoute = isAlreadySelected ? nil : TransactionHistoryState.Route.showTransaction(transcation)
        send(.transactionHistory(.setRoute(newRoute)))
    }

    var selectedTranactionID: Int? {
        self.transactionHistoryState
            .route
            .flatMap(/TransactionHistoryState.Route.showTransaction)
            .map(\.id)
    }

    func bindingForRoute(_ route: HomeState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

// MARK: PlaceHolders

extension HomeState {
    static var placeholder: Self {
        .init(
            transactionHistoryState: .placeHolder,
            profileState: .placeholder,
            route: nil
        )
    }
}
