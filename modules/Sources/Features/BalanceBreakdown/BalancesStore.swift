//
//  BalancesStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 04.08.2022.
//

import SwiftUI
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
import ZcashSDKEnvironment
import ShieldingProcessor

@Reducer
public struct Balances {
    @ObservableState
    public struct State: Equatable {
        public var stateStreamCancelId = UUID()
        public var shieldingProcessorCancelId = UUID()

        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var isShielding: Bool
        public var pendingTransactions: Zatoshi
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var shieldedBalance: Zatoshi
        public var shieldedWithPendingBalance: Zatoshi = .zero
        public var spendability: Spendability = .everything
        public var totalBalance: Zatoshi = .zero
        public var transparentBalance: Zatoshi

        public var isPendingInProcess: Bool {
            changePending.amount + pendingTransactions.amount > 0
        }
        
        public var isShieldableBalanceAvailable: Bool {
            transparentBalance.amount >= autoShieldingThreshold.amount
        }

        public var isShieldingButtonDisabled: Bool {
            isShielding || !isShieldableBalanceAvailable
        }

        public var isProcessingZeroAvailableBalance: Bool {
            if shieldedBalance.amount == 0 && transparentBalance.amount > 0 {
                return false
            }
            
            return totalBalance.amount != shieldedBalance.amount && shieldedBalance.amount == 0
        }

        public init(
            autoShieldingThreshold: Zatoshi,
            changePending: Zatoshi,
            isShielding: Bool,
            pendingTransactions: Zatoshi,
            shieldedBalance: Zatoshi = .zero,
            transparentBalance: Zatoshi = .zero
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.isShielding = isShielding
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.transparentBalance = transparentBalance
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case dismissTapped
        case onAppear
        case onDisappear
        case sheetHeightUpdated(CGFloat)
        case shieldFundsTapped
        case shieldingProcessorStateChanged(ShieldingProcessorClient.State)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateBalance(AccountBalance?)
        case updateBalances([AccountUUID: AccountBalance])
        case updateBalancesOnAppear
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.shieldingProcessor) var shieldingProcessor
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.autoShieldingThreshold = zcashSDKEnvironment.shieldingThreshold
                return .merge(
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { $0.redacted }
                            .map(Action.synchronizerStateChanged)
                    }
                    .cancellable(id: state.stateStreamCancelId, cancelInFlight: true),
                    .publisher {
                        shieldingProcessor.observe()
                            .map(Action.shieldingProcessorStateChanged)
                    }
                    .cancellable(id: state.shieldingProcessorCancelId, cancelInFlight: true),
                    .send(.updateBalancesOnAppear)
                )
                
            case .onDisappear:
                return .merge(
                    .cancel(id: state.stateStreamCancelId),
                    .cancel(id: state.shieldingProcessorCancelId)
                )
            
            case .shieldingProcessorStateChanged(let shieldingProcessorState):
                state.isShielding = shieldingProcessorState == .requested
                if shieldingProcessorState == .succeeded {
                    return .send(.updateBalancesOnAppear)
                }
                return .none

            case .updateBalancesOnAppear:
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                return .run { send in
                    if let accountBalance = try? await sdkSynchronizer.getAccountsBalances()[account.id] {
                        await send(.updateBalance(accountBalance))
                    } else if let accountBalance = sdkSynchronizer.latestState().accountsBalances[account.id] {
                        await send(.updateBalance(accountBalance))
                    }
                }

            case .sheetHeightUpdated:
                return .none
                
            case .dismissTapped:
                return .none
                
            case .shieldFundsTapped:
                shieldingProcessor.shieldFunds()
                return .none

            case .synchronizerStateChanged(let latestState):
                return .send(.updateBalances(latestState.data.accountsBalances))

            case .updateBalances(let accountsBalances):
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                return .send(.updateBalance(accountsBalances[account.id]))

            case .updateBalance(let accountBalance):
                state.changePending = (accountBalance?.saplingBalance.changePendingConfirmation ?? .zero) +
                    (accountBalance?.orchardBalance.changePendingConfirmation ?? .zero)
                state.pendingTransactions = (accountBalance?.saplingBalance.valuePendingSpendability ?? .zero) +
                    (accountBalance?.orchardBalance.valuePendingSpendability ?? .zero)
                state.shieldedBalance = (accountBalance?.saplingBalance.spendableValue ?? .zero) + (accountBalance?.orchardBalance.spendableValue ?? .zero)
                state.transparentBalance = accountBalance?.unshielded ?? .zero

                state.totalBalance = state.shieldedWithPendingBalance + state.transparentBalance
                state.shieldedWithPendingBalance = (accountBalance?.saplingBalance.total() ?? .zero) + (accountBalance?.orchardBalance.total() ?? .zero)

                // spendability
                if state.isProcessingZeroAvailableBalance {
                    state.spendability = .nothing
                } else if state.shieldedBalance == state.totalBalance {
                    state.spendability = .everything
                } else {
                    state.spendability = .something
                }
                return .none
            }
        }
    }
}
