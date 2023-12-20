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
import SyncProgress
import RestoreWalletStorage

public typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
public typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

public struct BalanceBreakdownReducer: Reducer {
    private enum CancelId { case timer }
    let networkType: NetworkType
    
    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var isRestoringWallet = false
        public var isShieldingFunds: Bool
        public var pendingTransactions: Zatoshi
        public var shieldedBalance: Balance
        public var syncProgressState: SyncProgressReducer.State
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
        
        public init(
            autoShieldingThreshold: Zatoshi,
            changePending: Zatoshi,
            isRestoringWallet: Bool = false,
            isShieldingFunds: Bool,
            pendingTransactions: Zatoshi,
            shieldedBalance: Balance,
            syncProgressState: SyncProgressReducer.State,
            transparentBalance: Balance
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.isRestoringWallet = isRestoringWallet
            self.isShieldingFunds = isShieldingFunds
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.syncProgressState = syncProgressState
            self.transparentBalance = transparentBalance
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case onAppear
        case onDisappear
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case shieldFunds
        case shieldFundsSuccess(TransactionState)
        case shieldFundsFailure(ZcashError)
        case synchronizerStateChanged(SynchronizerState)
        case syncProgress(SyncProgressReducer.Action)
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.syncProgressState, action: /Action.syncProgress) {
            SyncProgressReducer()
        }
        
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
                        .map(Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelId.timer, cancelInFlight: true)
                
            case .onDisappear:
                return .cancel(id: CancelId.timer)

            case .restoreWalletTask:
                return .run { send in
                    for await value in await restoreWalletStorage.value() {
                        await send(.restoreWalletValue(value))
                    }
                }

            case .restoreWalletValue(let value):
                state.isRestoringWallet = value
                return .none

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
                return .none
                
            case .syncProgress:
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
        syncProgressState: .initial,
        transparentBalance: Balance.zero
    )
    
    public static let initial = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        changePending: .zero,
        isShieldingFunds: false,
        pendingTransactions: .zero,
        shieldedBalance: Balance.zero,
        syncProgressState: .initial,
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
