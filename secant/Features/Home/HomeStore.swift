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
        enum Destination: Equatable {
            case notEnoughFreeDiskSpace
            case profile
            case request
            case transactionHistory
            case send
            case scan
            case balanceBreakdown
        }

        var destination: Destination?

        var balanceBreakdownState: BalanceBreakdownReducer.State
        var profileState: ProfileReducer.State
        var requestState: RequestReducer.State
        var requiredTransactionConfirmations = 0
        var scanState: ScanReducer.State
        var sendState: SendFlowReducer.State
        var shieldedBalance: Balance
        var synchronizerStatusSnapshot: SyncStatusSnapshot
        var walletEventsState: WalletEventsFlowReducer.State
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
        var zecPrice = Decimal(140.0)

        var totalCurrencyBalance: Zatoshi {
            Zatoshi.from(decimal: shieldedBalance.data.total.decimalValue.decimalValue * zecPrice)
        }

        var isSyncing: Bool {
            if case .syncing = synchronizerStatusSnapshot.syncStatus {
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
        case rewindDone(Bool, SettingsReducer.Action)
        case send(SendFlowReducer.Action)
        case scan(ScanReducer.Action)
        case synchronizerStateChanged(SDKSynchronizerState)
        case walletEvents(WalletEventsFlowReducer.Action)
        case updateDestination(HomeReducer.State.Destination?)
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
                    return .concatenate(EffectTask(value: .updateDestination(nil)), syncEffect)
                } else {
                    return EffectTask(value: .updateDestination(.notEnoughFreeDiskSpace))
                }

            case .onDisappear:
                return .cancel(id: CancelId.self)

            case .synchronizerStateChanged:
                return EffectTask(value: .updateSynchronizerStatus)
                                
            case .updateWalletEvents:
                return .none
                
            case .updateSynchronizerStatus:
                state.synchronizerStatusSnapshot = sdkSynchronizer.statusSnapshot()
                if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                    state.shieldedBalance = shieldedBalance.redacted
                }
                return .none
            
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

            case .profile(.settings(.quickRescan)):
                state.destination = nil
                return .run { send in
                    do {
                        try await sdkSynchronizer.rewind(.quick)
                        await send(.rewindDone(true, .quickRescan))
                    } catch {
                        await send(.rewindDone(false, .quickRescan))
                    }
                }

            case .profile(.settings(.fullRescan)):
                state.destination = nil
                return .run { send in
                    do {
                        try await sdkSynchronizer.rewind(.birthday)
                        await send(.rewindDone(true, .fullRescan))
                    } catch {
                        await send(.rewindDone(false, .fullRescan))
                    }
                }

            case .profile:
                return .none

            case .request:
                return .none

            case .rewindDone:
                // TODO: [#221] error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
                
            case .walletEvents:
                return .none
                
            case .send(.updateDestination(.done)):
                return EffectTask(value: .updateDestination(nil))
                
            case .send:
                return .none
                
            case .scan(.found):
                audioServices.systemSoundVibrate()
                return EffectTask(value: .updateDestination(nil))
                
            case .scan:
                return .none
                
            case .balanceBreakdown(.onDisappear):
                state.destination = nil
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
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: Balance.zero,
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
