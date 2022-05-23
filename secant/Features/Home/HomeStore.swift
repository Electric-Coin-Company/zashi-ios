import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

typealias HomeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
typealias HomeStore = Store<HomeState, HomeAction>
typealias HomeViewStore = ViewStore<HomeState, HomeAction>

// MARK: State

struct HomeState: Equatable {
    enum Route: Equatable {
        case profile
        case request
        case send
        case scan
    }

    var route: Route?

    var drawerOverlay: DrawerOverlay
    var profileState: ProfileState
    var requestState: RequestState
    var sendState: SendFlowState
    var scanState: ScanState
    var synchronizerStatus: String
    var totalBalance: Int64
    var transactionHistoryState: TransactionHistoryFlowState
    var verifiedBalance: Int64
}

// MARK: Action

enum HomeAction: Equatable {
    case debugMenuStartup
    case onAppear
    case onDisappear
    case profile(ProfileAction)
    case request(RequestAction)
    case send(SendFlowAction)
    case scan(ScanAction)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case transactionHistory(TransactionHistoryFlowAction)
    case updateBalance(Balance)
    case updateDrawer(DrawerOverlay)
    case updateRoute(HomeState.Route?)
    case updateSynchronizerStatus
    case updateTransactions([TransactionState])
}

// MARK: Environment

struct HomeEnvironment {
    let mnemonic: WrappedMnemonic
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WrappedWalletStorage
    let derivationTool: WrappedDerivationTool
    let SDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - Reducer

extension HomeReducer {
    private struct ListenerId: Hashable {}
    
    static let `default` = HomeReducer.combine(
        [
            homeReducer,
            historyReducer,
            sendReducer,
            profileReducer
        ]
    )
    .debug()

    private static let homeReducer = HomeReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.SDKSynchronizer.stateChanged
                .map(HomeAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: ListenerId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: ListenerId())

        case .synchronizerStateChanged(.synced):
            return .merge(
                environment.SDKSynchronizer.getAllClearedTransactions()
                    .receive(on: environment.scheduler)
                    .map(HomeAction.updateTransactions)
                    .eraseToEffect(),
                
                environment.SDKSynchronizer.getShieldedBalance()
                    .receive(on: environment.scheduler)
                    .map({ Balance(verified: $0.verified, total: $0.total) })
                    .map(HomeAction.updateBalance)
                    .eraseToEffect(),
                
                Effect(value: .updateSynchronizerStatus)
            )
            
        case .synchronizerStateChanged(let synchronizerState):
            return Effect(value: .updateSynchronizerStatus)
            
        case .updateBalance(let balance):
            state.totalBalance = balance.total
            state.verifiedBalance = balance.verified
            return .none
            
        case .updateDrawer(let drawerOverlay):
            state.drawerOverlay = drawerOverlay
            state.transactionHistoryState.isScrollable = drawerOverlay == .full ? true : false
            return .none
            
        case .updateTransactions(let transactions):
            return .none
            
        case .updateSynchronizerStatus:
            state.synchronizerStatus = environment.SDKSynchronizer.status()
            return .none
            
        case .updateRoute(let route):
            state.route = route
            return .none
            
        case .profile(let action):
            return .none

        case .request(let action):
            return .none

        case .scan(let action):
            return .none
            
        case .transactionHistory(.updateRoute(.all)):
            return state.drawerOverlay != .full ? Effect(value: .updateDrawer(.full)) : .none

        case .transactionHistory(.updateRoute(.latest)):
            return state.drawerOverlay != .partial ? Effect(value: .updateDrawer(.partial)) : .none

        case .transactionHistory(let historyAction):
            return .none
            
        case .send(.updateRoute(.done)):
            return Effect(value: .updateRoute(nil))
            
        case .send(let action):
            return .none
            
        case .debugMenuStartup:
            return .none
        }
    }
    
    private static let historyReducer: HomeReducer = TransactionHistoryFlowReducer.default.pullback(
        state: \HomeState.transactionHistoryState,
        action: /HomeAction.transactionHistory,
        environment: { environment in
            TransactionHistoryFlowEnvironment(
                scheduler: environment.scheduler,
                SDKSynchronizer: environment.SDKSynchronizer
            )
        }
    )
    
    private static let sendReducer: HomeReducer = SendFlowReducer.default.pullback(
        state: \HomeState.sendState,
        action: /HomeAction.send,
        environment: { environment in
            SendFlowEnvironment(
                mnemonic: environment.mnemonic,
                scheduler: environment.scheduler,
                walletStorage: environment.walletStorage,
                derivationTool: environment.derivationTool,
                SDKSynchronizer: environment.SDKSynchronizer
            )
        }
    )
    
    private static let profileReducer: HomeReducer = ProfileReducer.default.pullback(
        state: \HomeState.profileState,
        action: /HomeAction.profile,
        environment: { environment in
            ProfileEnvironment(
                mnemonic: environment.mnemonic,
                walletStorage: environment.walletStorage
            )
        }
    )
}

// MARK: - Store

extension HomeStore {
    func historyStore() -> TransactionHistoryFlowStore {
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

    func sendStore() -> SendFlowStore {
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

// MARK: - ViewStore

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

// MARK: Placeholders

extension HomeState {
    static var placeholder: Self {
        .init(
            drawerOverlay: .partial,
            profileState: .placeholder,
            requestState: .placeholder,
            sendState: .placeholder,
            scanState: .placeholder,
            synchronizerStatus: "",
            totalBalance: 0,
            transactionHistoryState: .emptyPlaceHolder,
            verifiedBalance: 0
        )
    }
}

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: .default.debug(),
            environment: HomeEnvironment(
                mnemonic: .live,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                walletStorage: .live(),
                derivationTool: .live(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer()
            )
        )
    }
}
