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
import Profile
import BalanceBreakdown
import WalletEventsFlow
import Scan
import Settings
import SendFlow

public typealias HomeStore = Store<HomeReducer.State, HomeReducer.Action>
public typealias HomeViewStore = ViewStore<HomeReducer.State, HomeReducer.Action>

public struct HomeReducer: ReducerProtocol {
    private enum CancelId { case timer }
    let networkType: NetworkType

    public struct State: Equatable {
        public enum Destination: Equatable {
            case balanceBreakdown
            case notEnoughFreeDiskSpace
            case profile
            case send
            case settings
            case transactionHistory
        }

        @PresentationState public var alert: AlertState<Action>?
        public var balanceBreakdownState: BalanceBreakdownReducer.State
        public var destination: Destination?
        public var canRequestReview = false
        public var profileState: ProfileReducer.State
        public var requiredTransactionConfirmations = 0
        public var scanState: ScanReducer.State
        public var sendState: SendFlowReducer.State
        public var settingsState: SettingsReducer.State
        public var shieldedBalance: Balance
        public var synchronizerStatusSnapshot: SyncStatusSnapshot
        public var walletConfig: WalletConfig
        public var walletEventsState: WalletEventsFlowReducer.State
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
        public var zecPrice = Decimal(140.0)

        public var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.verified.decimalValue.decimalValue * zecPrice)
        }

        public var isSyncing: Bool {
            if case .syncing = synchronizerStatusSnapshot.syncStatus {
                return true
            }
            return false
        }
        
        public var isUpToDate: Bool {
            if case .upToDate = synchronizerStatusSnapshot.syncStatus {
                return true
            }
            return false
        }

        public var isSendButtonDisabled: Bool {
            // If the destination is `.send` the button must be enabled
            // to avoid involuntary navigation pop.
            (self.destination != .send && self.isSyncing) || shieldedBalance.data.verified.amount == 0
        }
        
        public init(
            balanceBreakdownState: BalanceBreakdownReducer.State,
            destination: Destination? = nil,
            canRequestReview: Bool = false,
            profileState: ProfileReducer.State,
            requiredTransactionConfirmations: Int = 0,
            scanState: ScanReducer.State,
            sendState: SendFlowReducer.State,
            settingsState: SettingsReducer.State,
            shieldedBalance: Balance,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            walletConfig: WalletConfig,
            walletEventsState: WalletEventsFlowReducer.State,
            zecPrice: Decimal = Decimal(140.0)
        ) {
            self.balanceBreakdownState = balanceBreakdownState
            self.destination = destination
            self.canRequestReview = canRequestReview
            self.profileState = profileState
            self.requiredTransactionConfirmations = requiredTransactionConfirmations
            self.scanState = scanState
            self.sendState = sendState
            self.settingsState = settingsState
            self.shieldedBalance = shieldedBalance
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.walletConfig = walletConfig
            self.walletEventsState = walletEventsState
            self.zecPrice = zecPrice
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case debugMenuStartup
        case foundTransactions
        case onAppear
        case onDisappear
        case profile(ProfileReducer.Action)
        case resolveReviewRequest
        case retrySync
        case reviewRequestFinished
        case send(SendFlowReducer.Action)
        case settings(SettingsReducer.Action)
        case showSynchronizerErrorAlert(ZcashError)
        case synchronizerStateChanged(SynchronizerState)
        case syncFailed(ZcashError)
        case updateDestination(HomeReducer.State.Destination?)
        case updateWalletEvents([WalletEvent])
        case walletEvents(WalletEventsFlowReducer.Action)
    }
    
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.reviewRequest) var reviewRequest
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.walletEventsState, action: /Action.walletEvents) {
            WalletEventsFlowReducer()
        }

        Scope(state: \.sendState, action: /Action.send) {
            SendFlowReducer(networkType: networkType)
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
        }

        Scope(state: \.profileState, action: /Action.profile) {
            ProfileReducer()
        }

        Scope(state: \.balanceBreakdownState, action: /Action.balanceBreakdown) {
            BalanceBreakdownReducer(networkType: networkType)
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
                state.alert = AlertState.syncFailed(error, L10n.Home.SyncFailed.dismiss)
                return .none
                
            case .balanceBreakdown(.onDisappear):
                state.destination = nil
                return .none

            case .balanceBreakdown:
                return .none

            case .debugMenuStartup:
                return .none
                
            case .syncFailed(let error):
                state.alert = AlertState.syncFailed(error, L10n.General.ok)
                return .none

            case .alert(.presented(let action)):
                return EffectTask(value: action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

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

// MARK: Alerts

extension AlertState where Action == HomeReducer.Action {
    public static func syncFailed(_ error: ZcashError, _ secondaryButtonTitle: String) -> AlertState {
        AlertState {
            TextState(L10n.Home.SyncFailed.title)
        } actions: {
            ButtonState(action: .retrySync) {
                TextState(L10n.Home.SyncFailed.retry)
            }
            ButtonState(action: .alert(.dismiss)) {
                TextState(secondaryButtonTitle)
            }
        } message: {
            TextState("\(error.message) (code: \(error.code.rawValue))")
        }
    }
}

// MARK: Placeholders

extension HomeReducer.State {
    public static var placeholder: Self {
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
    public static var placeholder: HomeStore {
        HomeStore(
            initialState: .placeholder,
            reducer: HomeReducer(networkType: .testnet)
        )
    }

    public static var error: HomeStore {
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
            reducer: HomeReducer(networkType: .testnet)
        )
    }
}
