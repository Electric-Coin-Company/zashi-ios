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
    let network: ZcashNetwork
    
    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var isRestoringWallet = false
        public var isShieldingFunds: Bool
        public var isHintBoxVisible = false
        public var pendingTransactions: Zatoshi
        public var shieldedBalance: Zatoshi
        public var totalBalance: Zatoshi
        public var syncProgressState: SyncProgressReducer.State
        public var transparentBalance: Zatoshi

        public var isShieldableBalanceAvailable: Bool {
            transparentBalance.amount >= autoShieldingThreshold.amount
        }

        public var isShieldingButtonDisabled: Bool {
            isShieldingFunds || !isShieldableBalanceAvailable
        }
        
        public init(
            autoShieldingThreshold: Zatoshi,
            changePending: Zatoshi,
            isRestoringWallet: Bool = false,
            isShieldingFunds: Bool,
            isHintBoxVisible: Bool = false,
            pendingTransactions: Zatoshi,
            shieldedBalance: Zatoshi,
            syncProgressState: SyncProgressReducer.State,
            totalBalance: Zatoshi,
            transparentBalance: Zatoshi
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.isRestoringWallet = isRestoringWallet
            self.isShieldingFunds = isShieldingFunds
            self.isHintBoxVisible = isHintBoxVisible
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.totalBalance = totalBalance
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
        case updateHintBoxVisibility(Bool)
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage

    public init(network: ZcashNetwork) {
        self.network = network
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
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, network.networkType)

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
                state.shieldedBalance = latestState.accountBalance?.saplingBalance.spendableValue ?? .zero
                state.totalBalance = latestState.accountBalance?.saplingBalance.total() ?? .zero
                state.transparentBalance = latestState.accountBalance?.unshielded ?? .zero
                state.changePending = latestState.accountBalance?.saplingBalance.changePendingConfirmation ?? .zero
                state.pendingTransactions = latestState.accountBalance?.saplingBalance.valuePendingSpendability ?? .zero
                return .none
                
            case .syncProgress:
                return .none
                
            case .updateHintBoxVisibility(let visibility):
                state.isHintBoxVisible = visibility
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
        shieldedBalance: .zero,
        syncProgressState: .initial,
        totalBalance: .zero,
        transparentBalance: .zero
    )
    
    public static let initial = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        changePending: .zero,
        isShieldingFunds: false,
        pendingTransactions: .zero,
        shieldedBalance: .zero,
        syncProgressState: .initial,
        totalBalance: .zero,
        transparentBalance: .zero
    )
}

extension BalanceBreakdownStore {
    public static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder
    ) {
        BalanceBreakdownReducer(network: ZcashNetworkBuilder.network(for: .testnet))
    }
}
