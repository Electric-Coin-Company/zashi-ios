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

typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

struct BalanceBreakdownReducer: ReducerProtocol {
    private enum CancelId { case timer }
    
    struct State: Equatable {
        var autoShieldingThreshold: Zatoshi
        var latestBlock: String
        var shieldedBalance: Balance
        var shieldingFunds: Bool
        var transparentBalance: Balance
        
        var totalSpendableBalance: Zatoshi {
            shieldedBalance.data.verified + transparentBalance.data.verified
        }

        var isShieldableBalanceAvailable: Bool {
            transparentBalance.data.verified.amount >= autoShieldingThreshold.amount
        }

        var isShieldingButtonDisabled: Bool {
            shieldingFunds || !isShieldableBalanceAvailable
        }
    }

    enum Action: Equatable {
        case alert(AlertRequest)
        case onAppear
        case onDisappear
        case shieldFunds
        case shieldFundsSuccess
        case shieldFundsFailure(ZcashError)
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
        Reduce { state, action in
            switch action {
            case .alert:
                return .none

            case .onAppear:
                return sdkSynchronizer.stateStream()
                    .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                    .map(BalanceBreakdownReducer.Action.synchronizerStateChanged)
                    .eraseToEffect()
                    .cancellable(id: CancelId.timer, cancelInFlight: true)

            case .onDisappear:
                return .cancel(id: CancelId.timer)

            case .shieldFunds:
                state.shieldingFunds = true
                return .run { [state] send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, TargetConstants.zcashNetwork.networkType)

                        _ = try await sdkSynchronizer.shieldFunds(spendingKey, Memo(string: ""), state.autoShieldingThreshold)

                        await send(.shieldFundsSuccess)
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }

            case .shieldFundsSuccess:
                state.shieldingFunds = false
                return EffectTask(value: .alert(.balanceBreakdown(.shieldFundsSuccess)))

            case .shieldFundsFailure(let error):
                state.shieldingFunds = false
                return EffectTask(value: .alert(.balanceBreakdown(.shieldFundsFailure(error))))

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
