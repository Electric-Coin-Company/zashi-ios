import ComposableArchitecture
import SwiftUI

struct HomeState: Equatable {
    enum Route: Equatable {
        case profile
        case request
        case send
        case scan
    }

    var arePublishersPrepared = false
    var route: Route?

    var drawerOverlay: DrawerOverlay
    var profileState: ProfileState
    var requestState: RequestState
    var sendState: SendState
    var scanState: ScanState
    var totalBalance: Double
    var transactionHistoryState: TransactionHistoryState
    var verifiedBalance: Double
}

enum HomeAction: Equatable {
    case debugMenuStartup
    case preparePublishers
    case profile(ProfileAction)
    case request(RequestAction)
    case send(SendAction)
    case scan(ScanAction)
    case transactionHistory(TransactionHistoryAction)
    case updateBalance(Balance)
    case updateDrawer(DrawerOverlay)
    case updateRoute(HomeState.Route?)
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
            state.transactionHistoryState.isScrollable = drawerOverlay == .full ? true : false
            return .none
            
        case .transactionHistory(let historyAction):
            return TransactionHistoryReducer
                .default
                .run(&state.transactionHistoryState, historyAction, ())
                .map(HomeAction.transactionHistory)
            
        case .updateRoute(let route):
            state.route = route
            return .none
            
        case .profile(let action):
            return .none

        case .request(let action):
            return .none

        case .send(let action):
            return .none

        case .scan(let action):
            return .none
        }
    }
}

// MARK: - HomeViewStore

typealias HomeViewStore = ViewStore<HomeState, HomeAction>

extension HomeViewStore {
    func bindingForRoute(_ route: HomeState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
    
    func bindingForDrawer() -> Binding<DrawerOverlay> {
        self.binding(
            get: { $0.drawerOverlay },
            send: { .updateDrawer($0) }
        )
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

    func requestStore() -> RequestStore {
        self.scope(
            state: \.requestState,
            action: HomeAction.request
        )
    }

    func sendStore() -> SendStore {
        self.scope(
            state: \.sendState,
            action: HomeAction.send
        )
    }

    func scanStore() -> ScanStore {
        self.scope(
            state: \.scanState,
            action: HomeAction.scan
        )
    }
}

// MARK: PlaceHolders

extension HomeState {
    static var placeholder: Self {
        .init(
            drawerOverlay: .partial,
            profileState: .placeholder,
            requestState: .placeholder,
            sendState: .placeholder,
            scanState: .placeholder,
            totalBalance: 0.0,
            transactionHistoryState: .placeHolder,
            verifiedBalance: 0.0
        )
    }
}
