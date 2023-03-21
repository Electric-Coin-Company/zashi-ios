//
//  BalanceBreakdownStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

struct BalanceBreakdownReducer: ReducerProtocol {
    private enum CancelId {}
    
    struct State: Equatable {
        @BindingState var alert: AlertState<BalanceBreakdownReducer.Action>?
        var autoShieldingThreshold: Zatoshi
        var latestBlock: String
        var shieldedBalance: Balance
        var shieldingFunds: Bool
        var transparentBalance: Balance
        
        var totalBalance: Zatoshi {
            shieldedBalance.data.total + transparentBalance.data.total
        }

        var isShieldableBalanceAvailable: Bool {
            transparentBalance.data.verified.amount >= autoShieldingThreshold.amount
        }

        var isShieldingButtonDisabled: Bool {
            shieldingFunds || !isShieldableBalanceAvailable
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<BalanceBreakdownReducer.State>)
        case dismissAlert
        case onAppear
        case onDisappear
        case shieldFunds
        case shieldFundsSuccess
        case shieldFundsFailure(String)
        case synchronizerStateChanged(SynchronizerState)
        case updateLatestBlock
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .dismissAlert:
                state.alert = nil
                return .none

            case .onAppear:
                return sdkSynchronizer.stateStream()
                    .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                    .map(BalanceBreakdownReducer.Action.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: CancelId.self, cancelInFlight: true)

            case .onDisappear:
                return .cancel(id: CancelId.self)

            case .shieldFunds:
                state.shieldingFunds = true
                return .run { [state] send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0)

                        _ = try await sdkSynchronizer.shieldFunds(spendingKey, Memo(string: ""), state.autoShieldingThreshold)

                        await send(.shieldFundsSuccess)
                    } catch {
                        await send(.shieldFundsFailure(error.localizedDescription))
                    }
                }

            case .shieldFundsSuccess:
                state.shieldingFunds = false
                state.alert = AlertState(
                    title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.title),
                    message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.message),
                    dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
                )
                return .none

            case let .shieldFundsFailure(errorDescription):
                state.shieldingFunds = false
                state.alert = AlertState(
                    title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.title),
                    message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.message(errorDescription)),
                    dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
                )
                return .none

            case .synchronizerStateChanged(let latestState):
                state.shieldedBalance = latestState.shieldedBalance.redacted
                state.transparentBalance = latestState.transparentBalance.redacted
                return EffectTask(value: .updateLatestBlock)

            case .updateLatestBlock:
                let latestBlockNumber = sdkSynchronizer.latestScannedHeight()
                let latestBlock = numberFormatter.string(NSDecimalNumber(value: latestBlockNumber))
                state.latestBlock = "\(String(describing: latestBlock))"
                return .none
            }
        }
    }
}

// MARK: - Placeholders

extension BalanceBreakdownReducer.State {
    static let placeholder = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        latestBlock: L10n.General.unknown,
        shieldedBalance: Balance.zero,
        shieldingFunds: false,
        transparentBalance: Balance.zero
    )
}

extension BalanceBreakdownStore {
    static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: BalanceBreakdownReducer()
    )
}
