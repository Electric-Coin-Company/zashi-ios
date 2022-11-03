//
//  BalanceBreakdownStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

typealias BalanceBreakdownStore = Store<BalanceBreakdown.State, BalanceBreakdown.Action>

struct BalanceBreakdown: ReducerProtocol {
    private enum CancelId {}
    
    struct State: Equatable {
        var autoShieldingTreshold: Zatoshi
        var latestBlock: String
        var shieldedBalance: WalletBalance
        var transparentBalance: WalletBalance
        
        var totalBalance: Zatoshi {
            shieldedBalance.total + transparentBalance.total
        }
    }

    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    enum Action: Equatable {
        case onAppear
        case onDisappear
        case synchronizerStateChanged(WrappedSDKSynchronizerState)
        case updateLatestBlock
        case updateSynchronizerStatus
    }

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            return sdkSynchronizer.stateChanged
                .map(BalanceBreakdown.Action.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId.self, cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId.self)

        case .synchronizerStateChanged(.synced):
            return Effect(value: .updateSynchronizerStatus)
            
        case .synchronizerStateChanged:
            return Effect(value: .updateSynchronizerStatus)
            
        case .updateSynchronizerStatus:
            if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                state.shieldedBalance = shieldedBalance
            }
            if let transparentBalance = sdkSynchronizer.latestScannedSynchronizerState?.transparentBalance {
                state.transparentBalance = transparentBalance
            }
            return Effect(value: .updateLatestBlock)
            
        case .updateLatestBlock:
            guard let latestBlockNumber = sdkSynchronizer.latestScannedSynchronizerState?.latestScannedHeight,
            let latestBlock = numberFormatter.string(NSDecimalNumber(value: latestBlockNumber)) else {
                state.latestBlock = "unknown"
                return .none
            }
            state.latestBlock = "\(latestBlock)"
            return .none
        }
    }
}

// MARK: - Placeholders

extension BalanceBreakdown.State {
    static let placeholder = BalanceBreakdown.State(
        autoShieldingTreshold: Zatoshi(1_000_000),
        latestBlock: "unknown",
        shieldedBalance: WalletBalance.zero,
        transparentBalance: WalletBalance.zero
    )
}

extension BalanceBreakdownStore {
    static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: BalanceBreakdown()
    )
}
