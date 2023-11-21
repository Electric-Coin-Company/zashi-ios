//
//  BalanceBreakdownStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import DerivationTool
import MnemonicClient
import NumberFormatter
import Utils
import Generated
import WalletStorage
import SDKSynchronizer
import Models

public typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
public typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

public struct BalanceBreakdownReducer: Reducer {
    private enum CancelId { case timer }
    let networkType: NetworkType
    
    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var isShieldingFunds: Bool
        public var lastKnownSyncPercentage: Float = 0
        public var pendingTransactions: Zatoshi
        public var shieldedBalance: Balance
        public var synchronizerStatusSnapshot: SyncStatusSnapshot
        public var syncStatusMessage = ""
        public var transparentBalance: Balance

        public var totalBalance: Zatoshi {
            shieldedBalance.data.total + transparentBalance.data.total
        }

        public var isShieldableBalanceAvailable: Bool {
            transparentBalance.data.verified.amount >= autoShieldingThreshold.amount
        }

        public var isShieldingButtonDisabled: Bool {
            isShieldingFunds || !isShieldableBalanceAvailable
        }
        
        public var isSyncing: Bool {
            synchronizerStatusSnapshot.syncStatus.isSyncing
        }
        
        public var syncingPercentage: Float {
            if case .syncing(let progress) = synchronizerStatusSnapshot.syncStatus {
                return progress * 0.999
            }
            
            return lastKnownSyncPercentage
        }
        
        public init(
            autoShieldingThreshold: Zatoshi,
            changePending: Zatoshi,
            isShieldingFunds: Bool,
            lastKnownSyncPercentage: Float = 0,
            pendingTransactions: Zatoshi,
            shieldedBalance: Balance,
            synchronizerStatusSnapshot: SyncStatusSnapshot,
            syncStatusMessage: String = "",
            transparentBalance: Balance
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.isShieldingFunds = isShieldingFunds
            self.lastKnownSyncPercentage = lastKnownSyncPercentage
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.synchronizerStatusSnapshot = synchronizerStatusSnapshot
            self.syncStatusMessage = syncStatusMessage
            self.transparentBalance = transparentBalance
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case onAppear
        case onDisappear
        case shieldFunds
        case shieldFundsSuccess(TransactionState)
        case shieldFundsFailure(ZcashError)
        case synchronizerStateChanged(SynchronizerState)
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .onAppear:
                return .publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map(BalanceBreakdownReducer.Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelId.timer, cancelInFlight: true)
                
            case .onDisappear:
                return .cancel(id: CancelId.timer)

            case .shieldFunds:
                state.isShieldingFunds = true
                return .run { [state] send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, networkType)

                        let transaction = try await sdkSynchronizer.shieldFunds(spendingKey, Memo(string: ""), state.autoShieldingThreshold)

                        await send(.shieldFundsSuccess(transaction))
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }

            case .shieldFundsSuccess:
                state.isShieldingFunds = false
                state.transparentBalance = .zero
                return .none

            case .shieldFundsFailure(let error):
                state.isShieldingFunds = false
                state.alert = AlertState.shieldFundsFailure(error)
                return .none

            case .synchronizerStateChanged(let latestState):
                state.shieldedBalance = latestState.shieldedBalance.redacted
                state.transparentBalance = latestState.transparentBalance.redacted
                
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.syncStatus)
                if snapshot.syncStatus != state.synchronizerStatusSnapshot.syncStatus {
                    state.synchronizerStatusSnapshot = snapshot
                    
                    if case .syncing(let progress) = snapshot.syncStatus {
                        state.lastKnownSyncPercentage = progress
                    }
                    
                    // TODO: [#931] The statuses of the sync process
                    // https://github.com/Electric-Coin-Company/zashi-ios/issues/931
                    // until then, this is temporary quick solution
                    switch snapshot.syncStatus {
                    case .syncing:
                        state.syncStatusMessage = L10n.Balances.syncing
                    case .upToDate:
                        state.lastKnownSyncPercentage = 1
                        state.syncStatusMessage = L10n.Balances.synced
                    case .error, .stopped, .unprepared:
                        state.syncStatusMessage = snapshot.message
                    }
                }

                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == BalanceBreakdownReducer.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.message, error.code.rawValue))
        }
    }
}

// MARK: - Placeholders

extension BalanceBreakdownReducer.State {
    public static let placeholder = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        changePending: .zero,
        isShieldingFunds: false,
        pendingTransactions: .zero,
        shieldedBalance: Balance.zero,
        synchronizerStatusSnapshot: .placeholder,
        transparentBalance: Balance.zero
    )
    
    public static let initial = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        changePending: .zero,
        isShieldingFunds: false,
        pendingTransactions: .zero,
        shieldedBalance: Balance.zero,
        synchronizerStatusSnapshot: .initial,
        transparentBalance: Balance.zero
    )
}

extension BalanceBreakdownStore {
    public static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder
    ) {
        BalanceBreakdownReducer(networkType: .testnet)
    }
}
