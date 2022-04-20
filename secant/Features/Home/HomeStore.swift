import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    var arePublishersPrepared = false

    var drawerOverlay: DrawerOverlay
    var totalBalance: Double
    var transactionHistoryState: TransactionHistoryState
    var verifiedBalance: Double
}

enum HomeAction: Equatable {
    case debugMenuStartup
    case preparePublishers
    case transactionHistory(TransactionHistoryAction)
    case updateBalance(Balance)
    case updateDrawer(DrawerOverlay)
}

struct HomeEnvironment {
    let combineSynchronizer: CombineSynchronizer
}

// MARK: - HomeReducer

typealias HomeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>

extension HomeReducer {
    static let `default` = HomeReducer { state, action, environment in
        switch action {
        case .preparePublishers:
            if !state.arePublishersPrepared {
                state.arePublishersPrepared = true
                
                return environment.combineSynchronizer.shieldedBalance
                    .receive(on: DispatchQueue.main)
                    .map({ Balance(verified: $0.verified, total: $0.total) })
                    .map(HomeAction.updateBalance)
                    .eraseToEffect()
            }
            return .none
            
        case .updateBalance(let balance):
            state.totalBalance = balance.total.asHumanReadableZecBalance()
            state.verifiedBalance = balance.verified.asHumanReadableZecBalance()
            return .none
            
        case .debugMenuStartup:
            return .none

        case .updateDrawer(let drawerOverlay):
            state.drawerOverlay = drawerOverlay
            return .none
            
        case .transactionHistory(let historyAction):
            return TransactionHistoryReducer
                .default
                .run(&state.transactionHistoryState, historyAction, ())
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
    func bindingForDrawer() -> Binding<DrawerOverlay> {
        self.binding(
            get: { $0.drawerOverlay },
            send: { .updateDrawer($0) }
        )
    }
}

// MARK: PlaceHolders

extension HomeState {
    static var placeholder: Self {
        .init(
            drawerOverlay: .partial,
            totalBalance: 0.0,
            transactionHistoryState: .placeHolder,
            verifiedBalance: 0.0
        )
    }
}
