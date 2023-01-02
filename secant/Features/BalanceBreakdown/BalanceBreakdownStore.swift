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

struct BalanceBreakdownReducer: ReducerProtocol {
    private enum CancelId {}
    
    struct State: Equatable {
        var autoShieldingThreshold: Zatoshi
        var latestBlock: String
        var shieldedBalance: WalletBalance
        var transparentBalance: WalletBalance
        
        var totalBalance: Zatoshi {
            shieldedBalance.total + transparentBalance.total
        }
    }

    enum Action: Equatable {
        case onAppear
        case onDisappear
        case synchronizerStateChanged(SDKSynchronizerState)
        case updateLatestBlock
        case updateSynchronizerStatus
    }
    
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .onAppear:
            return sdkSynchronizer.stateChanged
                .map(BalanceBreakdownReducer.Action.synchronizerStateChanged)
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

extension BalanceBreakdownReducer.State {
    static let placeholder = BalanceBreakdownReducer.State(
        autoShieldingThreshold: Zatoshi(1_000_000),
        latestBlock: "unknown",
        shieldedBalance: WalletBalance.zero,
        transparentBalance: WalletBalance.zero
    )
}

extension BalanceBreakdownStore {
    static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: BalanceBreakdownReducer()
    )
}
