import UIKit
import SwiftUI
import AVFoundation
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import DiskSpaceChecker
import Utils
import Models
import Generated
import ReviewRequest

typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

struct HomeReducer: ReducerProtocol {
    private enum CancelId { case timer }

    struct State: Equatable {
        enum Destination: Equatable {
            case balanceBreakdown
            case notEnoughFreeDiskSpace
            case profile
            case send
            case settings
            case transactionHistory
        }

        var balanceBreakdownState: BalanceBreakdownReducer.State
        var destination: Destination?
        var canRequestReview = false
        var profileState: ProfileReducer.State
        var requiredTransactionConfirmations = 0
        var scanState: ScanReducer.State
        var sendState: SendFlowReducer.State
        var settingsState: SettingsReducer.State
        var shieldedBalance: Balance
        var synchronizerStatusSnapshot: SyncStatusSnapshot
        var walletConfig: WalletConfig
        var walletEventsState: WalletEventsFlowReducer.State
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
        var zecPrice = Decimal(140.0)

        var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.verified.decimalValue.decimalValue * zecPrice)
        }

        var isSyncing: Bool {
            if case .syncing = synchronizerStatusSnapshot.syncStatus {
                return true
            }
            return false
        }
        
        var isUpToDate: Bool {
            if case .upToDate = synchronizerStatusSnapshot.syncStatus {
                return true
            }
            return false
        }

        var isSendButtonDisabled: Bool {
            // If the destination is `.send` the button must be enabled
            // to avoid involuntary navigation pop.
            (self.destination != .send && self.isSyncing) || shieldedBalance.data.verified.amount == 0
        }
    }

    enum Action: Equatable {
        case alert(AlertRequest)
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case debugMenuStartup
        case onAppear
        case onDisappear
        case profile(ProfileReducer.Action)
        case resolveReviewRequest
        case reviewRequestFinished
        case send(SendFlowReducer.Action)
        case settings(SettingsReducer.Action)
        case syncFailed(ZcashError)
        case foundTransactions
        case synchronizerStateChanged(SynchronizerState)
        case walletEvents(WalletEventsFlowReducer.Action)
        case updateDestination(HomeReducer.State.Destination?)
        case showSynchronizerErrorAlert(ZcashError)
        case retrySync
        case updateWalletEvents([WalletEvent])
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.walletEventsState, action: /Action.walletEvents) {
            WalletEventsFlowReducer()
        }

        Scope(state: \.sendState, action: /Action.send) {
            SendFlowReducer()
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
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
                    let syncEffect = sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map(HomeReducer.Action.synchronizerStateChanged)
                        .eraseToEffect()
                        .cancellable(id: CancelId.timer, cancelInFlight: true)
                    return .merge(
                        EffectTask(value: .updateDestination(nil)),
                        syncEffect
                    )
                } else {
                    return EffectTask(value: .updateDestination(.notEnoughFreeDiskSpace))
                }
                
            case .onDisappear:
                return .cancel(id: CancelId.timer)
                
            case .resolveReviewRequest:
                if reviewRequest.canRequestReview() {
                    state.canRequestReview = true
                    return .fireAndForget { reviewRequest.reviewRequested() }
                }
                return .none
                
            case .reviewRequestFinished:
                state.canRequestReview = false
                return .none
                                
            case .updateWalletEvents:
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.syncStatus)

                guard snapshot != state.synchronizerStatusSnapshot else {
                    return .none
                }

                state.synchronizerStatusSnapshot = snapshot
                state.shieldedBalance = latestState.shieldedBalance.redacted

                switch snapshot.syncStatus {
                case .error(let error):
                    return EffectTask(value: .showSynchronizerErrorAlert(error.toZcashError()))

                case .upToDate:
                    return .fireAndForget { reviewRequest.syncFinished() }

                default:
                    return .none
                }

            case .foundTransactions:
                return .fireAndForget { reviewRequest.foundTransactions() }

            case .updateDestination(.profile):
                state.profileState.destination = nil
                state.destination = .profile
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none
                
            case .profile(.back):
                state.destination = nil
                return .none
            
            case .settings:
                return .none

            case .profile:
                return .none
                
            case .walletEvents:
                return .none
                
            case .send(.updateDestination(.done)):
                return EffectTask(value: .updateDestination(nil))
                
            case .send:
                return .none

            case .retrySync:
                return .run { send in
                    do {
                        try await sdkSynchronizer.start(true)
                    } catch {
                        await send(.syncFailed(error.toZcashError()))
                    }
                }

            case .showSynchronizerErrorAlert(let error):
                return EffectTask(value: .alert(.home(.syncFailed(error, L10n.Home.SyncFailed.dismiss))))
                
            case .balanceBreakdown(.onDisappear):
                state.destination = nil
                return .none

            case .balanceBreakdown:
                return .none

            case .debugMenuStartup:
                return .none
                
            case .syncFailed(let error):
                return EffectTask(value: .alert(.home(.syncFailed(error, L10n.General.ok))))
                
            case .alert:
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

    func sendStore() -> SendFlowStore {
        self.scope(
            state: \.sendState,
            action: HomeReducer.Action.send
        )
    }

    func settingsStore() -> SettingsStore {
        self.scope(
            state: \.settingsState,
            action: HomeReducer.Action.settings
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
    func bindingForDestination(_ destination: HomeReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}

// MARK: Placeholders

extension HomeReducer.State {
    static var placeholder: Self {
        .init(
            balanceBreakdownState: .placeholder,
            profileState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            settingsState: .placeholder,
            shieldedBalance: Balance.zero,
            synchronizerStatusSnapshot: .default,
            walletConfig: .default,
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

    static var error: HomeStore {
        HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                profileState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                settingsState: .placeholder,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .snapshotFor(
                    state: .error(ZcashError.synchronizerNotPrepared)
                ),
                walletConfig: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
        )
    }
}
