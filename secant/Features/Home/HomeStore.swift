import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

import UIKit
import AVFoundation

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
    var totalBalance: Zatoshi
    var walletEventsState: WalletEventsFlowState
    var verifiedBalance: Zatoshi
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
    case walletEvents(WalletEventsFlowAction)
    case updateBalance(Balance)
    case updateDrawer(DrawerOverlay)
    case updateRoute(HomeState.Route?)
    case updateSynchronizerStatus
    case updateWalletEvents([WalletEvent])
}

// MARK: Environment

struct HomeEnvironment {
    let audioServices: WrappedAudioServices
    let derivationTool: WrappedDerivationTool
    let feedbackGenerator: WrappedFeedbackGenerator
    let mnemonic: WrappedMnemonic
    let scheduler: AnySchedulerOf<DispatchQueue>
    let SDKSynchronizer: WrappedSDKSynchronizer
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension HomeEnvironment {
    static let demo = HomeEnvironment(
        audioServices: .silent,
        derivationTool: .live(),
        feedbackGenerator: .silent,
        mnemonic: .mock,
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        SDKSynchronizer: MockWrappedSDKSynchronizer(),
        walletStorage: .throwing,
        zcashSDKEnvironment: .testnet
    )
}

// MARK: - Reducer

extension HomeReducer {
    private struct CancelId: Hashable {}
    
    static let `default` = HomeReducer.combine(
        [
            homeReducer,
            historyReducer,
            sendReducer,
            scanReducer,
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
                .cancellable(id: CancelId(), cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .synchronizerStateChanged(.synced):
            return .merge(
                environment.SDKSynchronizer.getAllClearedTransactions()
                    .receive(on: environment.scheduler)
                    .map(HomeAction.updateWalletEvents)
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
            state.totalBalance = Zatoshi(amount: balance.total)
            state.verifiedBalance = Zatoshi(amount: balance.verified)
            return .none
            
        case .updateDrawer(let drawerOverlay):
            state.drawerOverlay = drawerOverlay
            state.walletEventsState.isScrollable = drawerOverlay == .full ? true : false
            return .none
            
        case .updateWalletEvents(let walletEvents):
            return .none
            
        case .updateSynchronizerStatus:
            state.synchronizerStatus = environment.SDKSynchronizer.status()
            return .none

        case .updateRoute(let route):
            state.route = route
            return .none
            
        case .profile(.back):
            state.route = nil
            return .none

        case .profile(let action):
            return .none

        case .request(let action):
            return .none
            
        case .walletEvents(.updateRoute(.all)):
            return state.drawerOverlay != .full ? Effect(value: .updateDrawer(.full)) : .none

        case .walletEvents(.updateRoute(.latest)):
            return state.drawerOverlay != .partial ? Effect(value: .updateDrawer(.partial)) : .none

        case .walletEvents(let historyAction):
            return .none
            
        case .send(.updateRoute(.done)):
            return Effect(value: .updateRoute(nil))
            
        case .send(let action):
            return .none
            
        case .scan(.found(let code)):
            environment.audioServices.systemSoundVibrate()
            return Effect(value: .updateRoute(nil))
            
        case .scan(let action):
            return .none
            
        case .debugMenuStartup:
            return .none
        }
    }
    
    private static let historyReducer: HomeReducer = WalletEventsFlowReducer.default.pullback(
        state: \HomeState.walletEventsState,
        action: /HomeAction.walletEvents,
        environment: { environment in
            WalletEventsFlowEnvironment(
                pasteboard: .live,
                scheduler: environment.scheduler,
                SDKSynchronizer: environment.SDKSynchronizer,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )
    
    private static let sendReducer: HomeReducer = SendFlowReducer.default.pullback(
        state: \HomeState.sendState,
        action: /HomeAction.send,
        environment: { environment in
            SendFlowEnvironment(
                derivationTool: environment.derivationTool,
                mnemonic: environment.mnemonic,
                numberFormatter: .live(),
                SDKSynchronizer: environment.SDKSynchronizer,
                scheduler: environment.scheduler,
                walletStorage: environment.walletStorage
            )
        }
    )
    
    private static let scanReducer: HomeReducer = ScanReducer.default.pullback(
        state: \HomeState.scanState,
        action: /HomeAction.scan,
        environment: { environment in
            ScanEnvironment(
                captureDevice: .real,
                scheduler: environment.scheduler,
                uriParser: .live(uriParser: URIParser(derivationTool: environment.derivationTool))
            )
        }
    )

    private static let profileReducer: HomeReducer = ProfileReducer.default.pullback(
        state: \HomeState.profileState,
        action: /HomeAction.profile,
        environment: { environment in
            ProfileEnvironment(
                appVersionHandler: .live,
                mnemonic: environment.mnemonic,
                SDKSynchronizer: environment.SDKSynchronizer,
                walletStorage: environment.walletStorage,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )
}

// MARK: - Store

extension HomeStore {
    func historyStore() -> WalletEventsFlowStore {
        self.scope(
            state: \.walletEventsState,
            action: HomeAction.walletEvents
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
            totalBalance: Zatoshi.zero,
            walletEventsState: .emptyPlaceHolder,
            verifiedBalance: Zatoshi.zero
        )
    }
}

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: .default.debug(),
            environment: HomeEnvironment(
                audioServices: .silent,
                derivationTool: .live(),
                feedbackGenerator: .silent,
                mnemonic: .live,
                scheduler: DispatchQueue.main.eraseToAnyScheduler(),
                SDKSynchronizer: LiveWrappedSDKSynchronizer(),
                walletStorage: .live(),
                zcashSDKEnvironment: .testnet
            )
        )
    }
}
