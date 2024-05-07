//
//  BalanceBreakdownStore.swift
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
import RestoreWalletStorage
import WalletBalances
import ZcashSDKEnvironment

public typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
public typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

public struct BalanceBreakdownReducer: Reducer {
    private let CancelId = UUID()
    
    public struct State: Equatable {
        public enum Destination: Equatable {
            case partialProposalError
        }

        @PresentationState public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var changePending: Zatoshi
        public var destination: Destination?
        public var isRestoringWallet = false
        public var isShieldingFunds: Bool
        public var isHintBoxVisible = false
        public var partialProposalErrorState: PartialProposalError.State
        public var pendingTransactions: Zatoshi
        public var shieldedBalance: Zatoshi
        public var syncProgressState: SyncProgressReducer.State
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
            isRestoringWallet: Bool = false,
            isShieldingFunds: Bool,
            isHintBoxVisible: Bool = false,
            partialProposalErrorState: PartialProposalError.State,
            pendingTransactions: Zatoshi,
            shieldedBalance: Zatoshi = .zero,
            syncProgressState: SyncProgressReducer.State,
            transparentBalance: Zatoshi = .zero,
            walletBalancesState: WalletBalances.State
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.changePending = changePending
            self.destination = destination
            self.isRestoringWallet = isRestoringWallet
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

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case onAppear
        case onDisappear
        case partialProposalError(PartialProposalError.Action)
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case shieldFunds
        case shieldFundsFailure(ZcashError)
        case shieldFundsPartial([String], [String])
        case shieldFundsSuccess
        case synchronizerStateChanged(RedactableSynchronizerState)
        case syncProgress(SyncProgressReducer.Action)
        case updateBalances(AccountBalance?)
        case updateDestination(BalanceBreakdownReducer.State.Destination?)
        case updateHintBoxVisibility(Bool)
        case walletBalances(WalletBalances.Action)
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.syncProgressState, action: /Action.syncProgress) {
            SyncProgressReducer()
        }
        
        Scope(state: \.partialProposalErrorState, action: /Action.partialProposalError) {
            PartialProposalError()
        }

        Scope(state: \.walletBalancesState, action: /Action.walletBalances) {
            WalletBalances()
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
                return .run { send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, zcashSDKEnvironment.network.networkType)
                        
                        guard let uAddress = try await sdkSynchronizer.getUnifiedAddress(0) else { throw "sdkSynchronizer.getUnifiedAddress" }

                        let address = try uAddress.transparentReceiver()
                        let proposal = try await sdkSynchronizer.proposeShielding(0, zcashSDKEnvironment.shieldingThreshold, .empty, address)
                        
                        guard let proposal else { throw "sdkSynchronizer.proposeShielding" }
                        
                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        await send(.walletBalances(.updateBalances))
                        
                        switch result {
                        case .failure:
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.shieldFundsPartial(txIds, statuses))
                        case .success:
                            await send(.shieldFundsSuccess)
                        }
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }

            case .shieldFundsFailure(let error):
                state.isShieldingFunds = false
                state.alert = AlertState.shieldFundsFailure(error)
                return .none

            case .shieldFundsSuccess:
                state.isShieldingFunds = false
                state.walletBalancesState.transparentBalance = .zero
                return .none

            case let .shieldFundsPartial(txIds, statuses):
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .send(.updateDestination(.partialProposalError))
                
            case .synchronizerStateChanged(let latestState):
                return .send(.updateBalances(latestState.data.accountBalance?.data))

            case .walletBalances(.balancesUpdated(let accountBalance)):
                state.shieldedBalance = state.walletBalancesState.shieldedBalance
                state.transparentBalance = state.walletBalancesState.transparentBalance
                return .send(.updateBalances(accountBalance))

            case .updateBalances(let accountBalance):
                state.changePending = (accountBalance?.saplingBalance.changePendingConfirmation ?? .zero) +
                    (accountBalance?.orchardBalance.changePendingConfirmation ?? .zero)
                state.pendingTransactions = (accountBalance?.saplingBalance.valuePendingSpendability ?? .zero) +
                    (accountBalance?.orchardBalance.valuePendingSpendability ?? .zero)
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

extension AlertState where Action == BalanceBreakdownReducer.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.detailedMessage))
        }
    }
}

// MARK: - Store

extension BalanceBreakdownStore {
    func partialProposalErrorStore() -> StoreOf<PartialProposalError> {
        self.scope(
            state: \.partialProposalErrorState,
            action: BalanceBreakdownReducer.Action.partialProposalError
        )
    }
}

// MARK: - ViewStore

extension BalanceBreakdownViewStore {
    var destinationBinding: Binding<BalanceBreakdownReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: BalanceBreakdownReducer.Action.updateDestination
        )
    }
    
    var bindingForPartialProposalError: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .partialProposalError },
            embed: { $0 ? BalanceBreakdownReducer.State.Destination.partialProposalError : nil }
        )
    }
}

// MARK: - Placeholders

extension BalanceBreakdownReducer.State {
    public static let placeholder = BalanceBreakdownReducer.State(
        autoShieldingThreshold: .zero,
        changePending: .zero,
        isShieldingFunds: false,
        partialProposalErrorState: .initial,
        pendingTransactions: .zero,
        syncProgressState: .initial,
        walletBalancesState: .initial
    )
    
    public static let initial = BalanceBreakdownReducer.State(
        autoShieldingThreshold: .zero,
        changePending: .zero,
        isShieldingFunds: false,
        partialProposalErrorState: .initial,
        pendingTransactions: .zero,
        syncProgressState: .initial,
        walletBalancesState: .initial
    )
}

extension BalanceBreakdownStore {
    public static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder
    ) {
        BalanceBreakdownReducer()
    }
}
