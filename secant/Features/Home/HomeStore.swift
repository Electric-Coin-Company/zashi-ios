import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

import UIKit
import AVFoundation

typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

struct HomeReducer: ReducerProtocol {
    private enum CancelId {}

    struct State: Equatable {
        enum Route: Equatable {
            case notEnoughFreeDiskSpace
            case profile
            case request
            case send
            case scan
            case balanceBreakdown
        }

        var route: Route?

        var balanceBreakdownState: BalanceBreakdownReducer.State
        var drawerOverlay: DrawerOverlay
        var profileState: ProfileReducer.State
        var requestState: RequestReducer.State
        var requiredTransactionConfirmations = 0
        var scanState: ScanReducer.State
        var sendState: SendFlowReducer.State
        var shieldedBalance: WalletBalance
        var synchronizerStatusSnapshot: SyncStatusSnapshot
        var walletEventsState: WalletEventsFlowReducer.State
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

    enum Action: Equatable {
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case debugMenuStartup
        case onAppear
        case onDisappear
        case profile(ProfileReducer.Action)
        case request(RequestReducer.Action)
        case send(SendFlowReducer.Action)
        case scan(ScanReducer.Action)
        case synchronizerStateChanged(WrappedSDKSynchronizerState)
        case walletEvents(WalletEventsFlowReducer.Action)
        case updateDrawer(DrawerOverlay)
        case updateRoute(HomeReducer.State.Route?)
        case updateSynchronizerStatus
        case updateWalletEvents([WalletEvent])
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.walletEventsState, action: /Action.walletEvents) {
            WalletEventsFlowReducer()
        }

        Scope(state: \.sendState, action: /Action.send) {
            SendFlowReducer()
        }

        Scope(state: \.scanState, action: /Action.scan) {
            ScanReducer()
        }

        Scope(state: \.profileState, action: /Action.profile) {
            ProfileReducer()
        }

        Scope(state: \.balanceBreakdownState, action: /Action.balanceBreakdown) {
            BalanceBreakdownReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.requiredTransactionConfirmations = zcashSDKEnvironment.requiredTransactionConfirmations

                if diskSpaceChecker.hasEnoughFreeSpaceForSync() {
                    let syncEffect = sdkSynchronizer.stateChanged
                        .map(HomeReducer.Action.synchronizerStateChanged)
                        .eraseToEffect()
                        .cancellable(id: CancelId.self, cancelInFlight: true)

                    return .concatenate(Effect(value: .updateRoute(nil)), syncEffect)
                } else {
                    return Effect(value: .updateRoute(.notEnoughFreeDiskSpace))
                }

            case .onDisappear:
                return Effect.cancel(id: CancelId.self)

            case .synchronizerStateChanged(.synced):
                return .merge(
                    sdkSynchronizer.getAllClearedTransactions()
                        .receive(on: mainQueue)
                        .map(HomeReducer.Action.updateWalletEvents)
                        .eraseToEffect(),
                    Effect(value: .updateSynchronizerStatus)
                )
                
            case .synchronizerStateChanged:
                return Effect(value: .updateSynchronizerStatus)
                
            case .updateDrawer(let drawerOverlay):
                state.drawerOverlay = drawerOverlay
                state.walletEventsState.isScrollable = drawerOverlay == .full ? true : false
                return .none
                
            case .updateWalletEvents:
                return .none
                
            case .updateSynchronizerStatus:
                state.synchronizerStatusSnapshot = sdkSynchronizer.statusSnapshot()
                if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
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
                    try sdkSynchronizer.rewind(.quick)
                } catch {
                    // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                state.route = nil
                return .none

            case .profile(.settings(.fullRescan)):
                do {
                    try sdkSynchronizer.rewind(.birthday)
                } catch {
                    // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                state.route = nil
                return .none

            case .profile:
                return .none

            case .request:
                return .none
                
            case .walletEvents(.updateRoute(.all)):
                return state.drawerOverlay != .full ? Effect(value: .updateDrawer(.full)) : .none

            case .walletEvents(.updateRoute(.latest)):
                return state.drawerOverlay != .partial ? Effect(value: .updateDrawer(.partial)) : .none

            case .walletEvents:
                return .none
                
            case .send(.updateRoute(.done)):
                return Effect(value: .updateRoute(nil))
                
            case .send:
                return .none
                
            case .scan(.found):
                audioServices.systemSoundVibrate()
                return Effect(value: .updateRoute(nil))
                
            case .scan:
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
    }
}

// MARK: - Store

extension HomeStore {
    func historyStore() -> WalletEventsFlowStore {
        self.scope(
            state: \.walletEventsState,
            action: HomeReducer.Action.walletEvents
        )
    }
    
    func profileStore() -> ProfileStore {
        self.scope(
            state: \.profileState,
            action: HomeReducer.Action.profile
        )
    }

    func requestStore() -> RequestStore {
        self.scope(
            state: \.requestState,
            action: HomeReducer.Action.request
        )
    }

    func sendStore() -> SendFlowStore {
        self.scope(
            state: \.sendState,
            action: HomeReducer.Action.send
        )
    }

    func scanStore() -> ScanStore {
        self.scope(
            state: \.scanState,
            action: HomeReducer.Action.scan
        )
    }

    func balanceBreakdownStore() -> BalanceBreakdownStore {
        self.scope(
            state: \.balanceBreakdownState,
            action: HomeReducer.Action.balanceBreakdown
        )
    }
}

// MARK: - ViewStore

extension HomeViewStore {
    func bindingForRoute(_ route: HomeReducer.State.Route) -> Binding<Bool> {
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

extension HomeReducer.State {
    static var placeholder: Self {
        .init(
            balanceBreakdownState: .placeholder,
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
            reducer: HomeReducer()
        )
    }
}
