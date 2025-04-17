//
//  BalancesStore.swift
//  secant-testnet
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

@Reducer
public struct Balances {
    private let CancelId = UUID()
    
    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var isShieldingFunds: Bool
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
            isShieldingFunds || !isShieldableBalanceAvailable
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
            isShieldingFunds: Bool,
            pendingTransactions: Zatoshi,
            shieldedBalance: Zatoshi = .zero,
            transparentBalance: Zatoshi = .zero
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.isShieldingFunds = isShieldingFunds
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.transparentBalance = transparentBalance
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case dismissTapped
        case onAppear
        case onDisappear
        case proposalReadyForShieldingWithKeystone(Proposal)
        case sheetHeightUpdated(CGFloat)
        case shieldFunds
        case shieldFundsFailure(ZcashError)
        case shieldFundsSuccess
        case shieldFundsWithKeystone
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
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none

            case .onAppear:
                state.autoShieldingThreshold = zcashSDKEnvironment.shieldingThreshold
                return .merge(
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { $0.redacted }
                            .map(Action.synchronizerStateChanged)
                    }
                    .cancellable(id: CancelId, cancelInFlight: true),
                    .send(.updateBalancesOnAppear)
                )
                
            case .onDisappear:
                return .cancel(id: CancelId)

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
                
            case .shieldFunds:
                guard let account = state.selectedWalletAccount, let zip32AccountIndex = account.zip32AccountIndex else {
                    return .none
                }
                if account.vendor == .keystone {
                    return .send(.shieldFundsWithKeystone)
                }
                // Regular path only for Zashi account
                state.isShieldingFunds = true
                return .run { send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, zcashSDKEnvironment.network.networkType)

                        let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)
                        
                        guard let proposal else { throw "sdkSynchronizer.proposeShielding" }
                        
                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        //await send(.walletBalances(.updateBalances))
                        
                        switch result {
                        case .grpcFailure:
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions-grpcFailure".toZcashError()))
                        case .failure:
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions-failure \(code) \(description)".toZcashError()))
                        case .partial:
                            return
                        case .success:
                            await send(.shieldFundsSuccess)
                        }
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }
                
            case .shieldFundsWithKeystone:
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                return .run { send in
                    do {
                        let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)
                        
                        guard let proposal else { throw "sdkSynchronizer.proposeShielding" }
                        await send(.proposalReadyForShieldingWithKeystone(proposal))
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }
                
            case .proposalReadyForShieldingWithKeystone:
                return .none

            case .shieldFundsFailure:
                state.isShieldingFunds = false
                //state.alert = AlertState.shieldFundsFailure(error)
                return .none

            case .shieldFundsSuccess:
                state.isShieldingFunds = false
                state.transparentBalance = .zero
                if let account = state.selectedWalletAccount {
                    walletStorage.resetShieldingReminder(account.account)
                }
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
//
//// MARK: Alerts
//
//extension AlertState where Action == Balances.Action {
//    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
//        AlertState {
//            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
//        } message: {
//            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.detailedMessage))
//        }
//    }
//}
