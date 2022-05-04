import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

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
    var sendState: SendState
    var scanState: ScanState
    var synchronizerStatus: String
    var totalBalance: Double
    var transactionHistoryState: TransactionHistoryState
    var verifiedBalance: Double
}

enum HomeAction: Equatable {
    case debugMenuStartup
    case onAppear
    case onDisappear
    case profile(ProfileAction)
    case request(RequestAction)
    case send(SendAction)
    case scan(ScanAction)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case transactionHistory(TransactionHistoryAction)
    case updateBalance(Balance)
    case updateDrawer(DrawerOverlay)
    case updateRoute(HomeState.Route?)
    case updateSynchronizerStatus
    case updateTransactions([TransactionState])
}

struct HomeEnvironment {
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WalletStorageInteractor
    let wrappedDerivationTool: WrappedDerivationTool
    let wrappedSDKSynchronizer: WrappedSDKSynchronizer
}

// MARK: - HomeReducer

private struct ListenerId: Hashable {}

typealias HomeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>

extension HomeReducer {
    static let `default` = HomeReducer.combine(
        [
            homeReducer,
            historyReducer,
            sendReducer
        ]
    )
    .debug()

    private static let homeReducer = HomeReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.wrappedSDKSynchronizer.stateChanged
                .map(HomeAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: ListenerId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: ListenerId())

        case .synchronizerStateChanged(.synced):
            return .merge(
                environment.wrappedSDKSynchronizer.getAllClearedTransactions()
                    .receive(on: environment.scheduler)
                    .map(HomeAction.updateTransactions)
                    .eraseToEffect(),
                
                environment.wrappedSDKSynchronizer.getShieldedBalance()
                    .receive(on: environment.scheduler)
                    .map({ Balance(verified: $0.verified, total: $0.total) })
                    .map(HomeAction.updateBalance)
                    .eraseToEffect(),
                
                Effect(value: .updateSynchronizerStatus)
            )
            
        case .synchronizerStateChanged(let synchronizerState):
            return Effect(value: .updateSynchronizerStatus)
            
        case .updateBalance(let balance):
            state.totalBalance = balance.total.asHumanReadableZecBalance()
            state.verifiedBalance = balance.verified.asHumanReadableZecBalance()
            return .none
            
        case .updateDrawer(let drawerOverlay):
            state.drawerOverlay = drawerOverlay
            state.transactionHistoryState.isScrollable = drawerOverlay == .full ? true : false
            return .none
            
        case .updateTransactions(let transactions):
            return .none
            
        case .updateSynchronizerStatus:
            state.synchronizerStatus = environment.wrappedSDKSynchronizer.status()
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
    
    private static let historyReducer: HomeReducer = TransactionHistoryReducer.default.pullback(
        state: \HomeState.transactionHistoryState,
        action: /HomeAction.transactionHistory,
        environment: { environment in
            TransactionHistoryEnvironment(
                scheduler: environment.scheduler,
                wrappedSDKSynchronizer: environment.wrappedSDKSynchronizer
            )
        }
    )
    
    private static let sendReducer: HomeReducer = SendReducer.default.pullback(
        state: \HomeState.sendState,
        action: /HomeAction.send,
        environment: { environment in
            SendEnvironment(
                mnemonicSeedPhraseProvider: environment.mnemonicSeedPhraseProvider,
                scheduler: environment.scheduler,
                walletStorage: environment.walletStorage,
                wrappedDerivationTool: environment.wrappedDerivationTool,
                wrappedSDKSynchronizer: environment.wrappedSDKSynchronizer
            )
        }
    )
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
            synchronizerStatus: "",
            totalBalance: 0.0,
            transactionHistoryState: .emptyPlaceHolder,
            verifiedBalance: 0.0
        )
    }
}

extension SDKSynchronizer {
    static func textFor(state: SyncStatus) -> String {
        switch state {
        case .downloading(let progress):
            return "Downloading \(progress.progressHeight)/\(progress.targetHeight)"

        case .enhancing(let enhanceProgress):
            return "Enhancing tx \(enhanceProgress.enhancedTransactions) of \(enhanceProgress.totalTransactions)"

        case .fetching:
            return "fetching UTXOs"

        case .scanning(let scanProgress):
            return "Scanning: \(scanProgress.progressHeight)/\(scanProgress.targetHeight)"

        case .disconnected:
            return "disconnected 💔"

        case .stopped:
            return "Stopped 🚫"

        case .synced:
            return "Synced 😎"

        case .unprepared:
            return "Unprepared 😅"

        case .validating:
            return "Validating"

        case .error(let err):
            return "Error: \(err.localizedDescription)"
        }
    }
}
