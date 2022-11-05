import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

import UIKit
import AVFoundation

typealias HomeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
typealias HomeStore = Store<HomeState, HomeAction>
typealias HomeViewStore = ViewStore<HomeState, HomeAction>

typealias AnyBalanceBreakdownReducer = AnyReducer<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action, HomeEnvironment>
typealias AnyScanReducer = AnyReducer<ScanReducer.State, ScanReducer.Action, HomeEnvironment>

// MARK: State

struct HomeState: Equatable {
    enum Route: Equatable {
        case notEnoughFreeDiskSpace
        case profile
        case request
        case send
        case scan
        case balanceBreakdown
    }

    var route: Route?

    var balanceBreakdown: BalanceBreakdownReducer.State
    var drawerOverlay: DrawerOverlay
    var profileState: ProfileState
    var requestState: RequestState
    var requiredTransactionConfirmations = 0
    var scanState: ScanReducer.State
    var sendState: SendFlowState
    var shieldedBalance: WalletBalance
    var synchronizerStatusSnapshot: SyncStatusSnapshot
    var walletEventsState: WalletEventsFlowState
    // TODO [#311]: - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
    var zecPrice = Decimal(140.0)

    var totalCurrencyBalance: Zatoshi {
        Zatoshi.from(decimal: shieldedBalance.total.decimalValue.decimalValue * zecPrice)
    }
    
    var isDownloading: Bool {
        if case .downloading = synchronizerStatusSnapshot.syncStatus {
            return true
        }
        return false
    }
    
    var isUpToDate: Bool {
        if case .synced = synchronizerStatusSnapshot.syncStatus {
            return true
        }
        return false
    }
}

// MARK: Action

enum HomeAction: Equatable {
    case balanceBreakdown(BalanceBreakdownReducer.Action)
    case debugMenuStartup
    case onAppear
    case onDisappear
    case profile(ProfileAction)
    case request(RequestAction)
    case send(SendFlowAction)
    case scan(ScanReducer.Action)
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case walletEvents(WalletEventsFlowAction)
    case updateDrawer(DrawerOverlay)
    case updateRoute(HomeState.Route?)
    case updateSynchronizerStatus
    case updateWalletEvents([WalletEvent])
}

// MARK: Environment

struct HomeEnvironment {
    let audioServices: WrappedAudioServices
    let derivationTool: WrappedDerivationTool
    let diskSpaceChecker: WrappedDiskSpaceChecker
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
        diskSpaceChecker: .mockEmptyDisk,
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
            profileReducer,
            balanceBreakdownReducer
        ]
    )

    private static let homeReducer = HomeReducer { state, action, environment in
        switch action {
        case .onAppear:
            state.requiredTransactionConfirmations = environment.zcashSDKEnvironment.requiredTransactionConfirmations

            if environment.diskSpaceChecker.hasEnoughFreeSpaceForSync() {
                let syncEffect = environment.SDKSynchronizer.stateChanged
                    .map(HomeAction.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: CancelId(), cancelInFlight: true)

                return .concatenate(Effect(value: .updateRoute(nil)), syncEffect)
            } else {
                return Effect(value: .updateRoute(.notEnoughFreeDiskSpace))
            }

        case .onDisappear:
            return Effect.cancel(id: CancelId())

        case .synchronizerStateChanged(.synced):
            return .merge(
                environment.SDKSynchronizer.getAllClearedTransactions()
                    .receive(on: environment.scheduler)
                    .map(HomeAction.updateWalletEvents)
                    .eraseToEffect(),
                Effect(value: .updateSynchronizerStatus)
            )
            
        case .synchronizerStateChanged(let synchronizerState):
            return Effect(value: .updateSynchronizerStatus)
            
        case .updateDrawer(let drawerOverlay):
            state.drawerOverlay = drawerOverlay
            state.walletEventsState.isScrollable = drawerOverlay == .full ? true : false
            return .none
            
        case .updateWalletEvents(let walletEvents):
            return .none
            
        case .updateSynchronizerStatus:
            state.synchronizerStatusSnapshot = environment.SDKSynchronizer.statusSnapshot()
            if let shieldedBalance = environment.SDKSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                state.shieldedBalance = shieldedBalance
            }
            return .none

        case .updateRoute(let route):
            state.route = route
            return .none
            
        case .profile(.back):
            state.route = nil
            return .none

        case .profile(.settings(.quickRescan)):
            do {
                try environment.SDKSynchronizer.rewind(.quick)
            } catch {
                // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
            }
            state.route = nil
            return .none

        case .profile(.settings(.fullRescan)):
            do {
                try environment.SDKSynchronizer.rewind(.birthday)
            } catch {
                // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
            }
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
            
        case .balanceBreakdown(.onDisappear):
            state.route = nil
            return .none

        case .balanceBreakdown:
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
                walletStorage: environment.walletStorage,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )
    
    private static let scanReducer: HomeReducer = AnyScanReducer { environment in
        ScanReducer()
            .dependency(\.uriParser, .live(uriParser: URIParser(derivationTool: environment.derivationTool)))
    }
    .pullback(
        state: \HomeState.scanState,
        action: /HomeAction.scan,
        environment: { $0 }
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
    
    private static let balanceBreakdownReducer: HomeReducer = AnyBalanceBreakdownReducer { _ in
        BalanceBreakdownReducer()
    }
    .pullback(
        state: \HomeState.balanceBreakdown,
        action: /HomeAction.balanceBreakdown,
        environment: { $0 }
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

    func balanceBreakdownStore() -> BalanceBreakdownStore {
        self.scope(
            state: \.balanceBreakdown,
            action: HomeAction.balanceBreakdown
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
            balanceBreakdown: .placeholder,
            drawerOverlay: .partial,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: WalletBalance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )
    }
}

extension HomeStore {
    static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: .default,
            environment: HomeEnvironment(
                audioServices: .silent,
                derivationTool: .live(),
                diskSpaceChecker: .mockEmptyDisk,
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
