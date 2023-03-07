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
        var shieldedBalance: Balance
        var transparentBalance: Balance
        
        var totalBalance: Zatoshi {
            shieldedBalance.data.total + transparentBalance.data.total
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
            return .cancel(id: CancelId.self)

        case .synchronizerStateChanged(.synced):
            return EffectTask(value: .updateSynchronizerStatus)
            
        case .synchronizerStateChanged:
            return EffectTask(value: .updateSynchronizerStatus)
            
        case .updateSynchronizerStatus:
            if let shieldedBalance = sdkSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                state.shieldedBalance = shieldedBalance.redacted
            }
            if let transparentBalance = sdkSynchronizer.latestScannedSynchronizerState?.transparentBalance {
                state.transparentBalance = transparentBalance.redacted
            }
            return EffectTask(value: .updateLatestBlock)
            
        case .updateLatestBlock:
            guard let latestBlockNumber = sdkSynchronizer.latestScannedSynchronizerState?.latestScannedHeight,
            let latestBlock = numberFormatter.string(NSDecimalNumber(value: latestBlockNumber)) else {
                state.latestBlock = L10n.General.unknown
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
        latestBlock: L10n.General.unknown,
        shieldedBalance: Balance.zero,
        transparentBalance: Balance.zero
    )
}

extension BalanceBreakdownStore {
    static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: BalanceBreakdownReducer()
    )
}
