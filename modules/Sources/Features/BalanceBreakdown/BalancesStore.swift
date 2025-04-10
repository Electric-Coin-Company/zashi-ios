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
import PartialProposalError
import Utils
import Generated
import WalletStorage
import SDKSynchronizer
import Models
import SyncProgress
import WalletBalances
import ZcashSDKEnvironment

@Reducer
public struct Balances {
    private let CancelId = UUID()
    
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case partialProposalError
        }

        @Presents public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var destination: Destination?
        public var isShieldingFunds: Bool
        public var isHintBoxVisible = false
        public var partialProposalErrorState: PartialProposalError.State
        public var pendingTransactions: Zatoshi
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var shieldedBalance: Zatoshi
        public var syncProgressState: SyncProgress.State
        public var transparentBalance: Zatoshi
        public var walletBalancesState: WalletBalances.State

        public var isShieldableBalanceAvailable: Bool {
            transparentBalance.amount >= autoShieldingThreshold.amount
        }

        public var isShieldingButtonDisabled: Bool {
            isShieldingFunds || !isShieldableBalanceAvailable
        }
                
        public init(
            autoShieldingThreshold: Zatoshi,
            changePending: Zatoshi,
            destination: Destination? = nil,
            isShieldingFunds: Bool,
            isHintBoxVisible: Bool = false,
            partialProposalErrorState: PartialProposalError.State,
            pendingTransactions: Zatoshi,
            shieldedBalance: Zatoshi = .zero,
            syncProgressState: SyncProgress.State,
            transparentBalance: Zatoshi = .zero,
            walletBalancesState: WalletBalances.State
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.destination = destination
            self.isShieldingFunds = isShieldingFunds
            self.isHintBoxVisible = isHintBoxVisible
            self.partialProposalErrorState = partialProposalErrorState
            self.pendingTransactions = pendingTransactions
            self.shieldedBalance = shieldedBalance
            self.syncProgressState = syncProgressState
            self.transparentBalance = transparentBalance
            self.walletBalancesState = walletBalancesState
        }
    }

    @CasePathable
    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case onAppear
        case onDisappear
        case partialProposalError(PartialProposalError.Action)
        case proposalReadyForShieldingWithKeystone(Proposal)
        case shieldFunds
        case shieldFundsFailure(ZcashError)
        case shieldFundsPartial([String], [String])
        case shieldFundsSuccess
        case shieldFundsWithKeystone
        case synchronizerStateChanged(RedactableSynchronizerState)
        case syncProgress(SyncProgress.Action)
        case updateBalance(AccountBalance?)
        case updateBalances([AccountUUID: AccountBalance])
        case updateDestination(Balances.State.Destination?)
        case updateHintBoxVisibility(Bool)
        case walletBalances(WalletBalances.Action)
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
        Scope(state: \.syncProgressState, action: \.syncProgress) {
            SyncProgress()
        }
        
        Scope(state: \.partialProposalErrorState, action: \.partialProposalError) {
            PartialProposalError()
        }

        Scope(state: \.walletBalancesState, action: \.walletBalances) {
            WalletBalances()
        }

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
                return .publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map { $0.redacted }
                        .map(Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelId, cancelInFlight: true)
                
            case .onDisappear:
                return .cancel(id: CancelId)
            
            case .partialProposalError:
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
                        case let .failure(txIds, code, description):
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions-failure \(code) \(description)".toZcashError()))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.shieldFundsPartial(txIds, statuses))
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

            case .shieldFundsFailure(let error):
                state.isShieldingFunds = false
                state.alert = AlertState.shieldFundsFailure(error)
                return .none

            case .shieldFundsSuccess:
                state.isShieldingFunds = false
                //state.walletBalancesState.transparentBalance = .zero
                state.transparentBalance = .zero
                if let account = state.selectedWalletAccount {
                    walletStorage.resetShieldingReminder(account.account)
                }
                return .none

            case let .shieldFundsPartial(txIds, statuses):
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .send(.updateDestination(.partialProposalError))
                
            case .synchronizerStateChanged(let latestState):
                return .send(.updateBalances(latestState.data.accountsBalances))

//            case .walletBalances(.balanceUpdated(let accountBalance)):
//                state.shieldedBalance = state.walletBalancesState.shieldedBalance
//                state.transparentBalance = state.walletBalancesState.transparentBalance
//                return .send(.updateBalance(accountBalance))

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
                return .none

            case .syncProgress:
                return .none

            case let .updateDestination(destination):
                state.destination = destination
                return .none

            case .updateHintBoxVisibility(let visibility):
                state.isHintBoxVisible = visibility
                return .none
                
            case .walletBalances:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == Balances.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.detailedMessage))
        }
    }
}
