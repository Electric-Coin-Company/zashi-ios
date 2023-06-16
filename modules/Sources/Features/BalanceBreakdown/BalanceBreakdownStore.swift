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

public typealias BalanceBreakdownStore = Store<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>
public typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownReducer.State, BalanceBreakdownReducer.Action>

public struct BalanceBreakdownReducer: ReducerProtocol {
    private enum CancelId { case timer }
    let networkType: NetworkType
    
    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var autoShieldingThreshold: Zatoshi
        public var latestBlock: String
        public var shieldedBalance: Balance
        public var shieldingFunds: Bool
        public var transparentBalance: Balance
        
        public var totalSpendableBalance: Zatoshi {
            shieldedBalance.data.verified + transparentBalance.data.verified
        }

        public var isShieldableBalanceAvailable: Bool {
            transparentBalance.data.verified.amount >= autoShieldingThreshold.amount
        }

        public var isShieldingButtonDisabled: Bool {
            shieldingFunds || !isShieldableBalanceAvailable
        }
        
        public init(
            autoShieldingThreshold: Zatoshi,
            latestBlock: String,
            shieldedBalance: Balance,
            shieldingFunds: Bool,
            transparentBalance: Balance
        ) {
            self.autoShieldingThreshold = autoShieldingThreshold
            self.latestBlock = latestBlock
            self.shieldedBalance = shieldedBalance
            self.shieldingFunds = shieldingFunds
            self.transparentBalance = transparentBalance
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
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

    public init(networkType: NetworkType) {
        self.networkType = networkType
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return EffectTask(value: action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

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
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, networkType)

                        _ = try await sdkSynchronizer.shieldFunds(spendingKey, Memo(string: ""), state.autoShieldingThreshold)

                        await send(.shieldFundsSuccess)
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }

            case .shieldFundsSuccess:
                state.shieldingFunds = false
                state.alert = AlertState.shieldFundsSuccess()
                return .none

            case .shieldFundsFailure(let error):
                state.shieldingFunds = false
                state.alert = AlertState.shieldFundsFailure(error)
                return .none

            case .synchronizerStateChanged(let latestState):
                state.shieldedBalance = latestState.shieldedBalance.redacted
                state.transparentBalance = latestState.transparentBalance.redacted
                return EffectTask(value: .updateLatestBlock)

            case .updateLatestBlock:
                let latestBlockNumber = sdkSynchronizer.latestScannedHeight()
                let latestBlock = numberFormatter.string(NSDecimalNumber(value: latestBlockNumber))
                state.latestBlock = "\(String(describing: latestBlock ?? ""))"
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == BalanceBreakdownReducer.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.message(error.message, error.code.rawValue))
        }
    }
    
    public static func shieldFundsSuccess() -> AlertState {
        AlertState {
            TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.title)
        } message: {
            TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.message)
        }
    }
}

// MARK: - Placeholders

extension BalanceBreakdownReducer.State {
    public static let placeholder = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        latestBlock: L10n.General.unknown,
        shieldedBalance: Balance.zero,
        shieldingFunds: false,
        transparentBalance: Balance.zero
    )
}

extension BalanceBreakdownStore {
    public static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: BalanceBreakdownReducer(networkType: .testnet)
    )
}
