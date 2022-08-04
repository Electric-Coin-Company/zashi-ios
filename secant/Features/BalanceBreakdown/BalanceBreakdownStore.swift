//
//  BalanceBreakdownStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.08.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

typealias BalanceBreakdownReducer = Reducer<BalanceBreakdownState, BalanceBreakdownAction, BalanceBreakdownEnvironment>
typealias BalanceBreakdownStore = Store<BalanceBreakdownState, BalanceBreakdownAction>
typealias BalanceBreakdownViewStore = ViewStore<BalanceBreakdownState, BalanceBreakdownAction>

// MARK: - State

struct BalanceBreakdownState: Equatable {
    var autoShieldingTreshold: Zatoshi
    var latestBlock: String
    var shieldedBalance: WalletBalance
    var transparentBalance: WalletBalance
    
    var totalBalance: Zatoshi {
        shieldedBalance.total + transparentBalance.total
    }
}

// MARK: - Action

enum BalanceBreakdownAction: Equatable {
    case onAppear
    case onDisappear
    case synchronizerStateChanged(WrappedSDKSynchronizerState)
    case updateLatestBlock
    case updateSynchronizerStatus
}

// MARK: - Environment

struct BalanceBreakdownEnvironment {
    let numberFormatter: WrappedNumberFormatter
    let SDKSynchronizer: WrappedSDKSynchronizer
    let scheduler: AnySchedulerOf<DispatchQueue>
}

extension BalanceBreakdownEnvironment {
    static let live = BalanceBreakdownEnvironment(
        numberFormatter: .live(),
        SDKSynchronizer: LiveWrappedSDKSynchronizer(),
        scheduler: DispatchQueue.main.eraseToAnyScheduler()
    )

    static let mock = BalanceBreakdownEnvironment(
        numberFormatter: .live(),
        SDKSynchronizer: MockWrappedSDKSynchronizer(),
        scheduler: DispatchQueue.main.eraseToAnyScheduler()
    )
}

// MARK: - Reducer

extension BalanceBreakdownReducer {
    private enum CancelId {}

    static let `default` = BalanceBreakdownReducer { state, action, environment in
        switch action {
        case .onAppear:
            return environment.SDKSynchronizer.stateChanged
                .map(BalanceBreakdownAction.synchronizerStateChanged)
                .eraseToEffect()
                .cancellable(id: CancelId.self, cancelInFlight: true)

        case .onDisappear:
            return Effect.cancel(id: CancelId.self)

        case .synchronizerStateChanged(.synced):
            return Effect(value: .updateSynchronizerStatus)
            
        case .synchronizerStateChanged(let synchronizerState):
            return Effect(value: .updateSynchronizerStatus)
            
        case .updateSynchronizerStatus:
            if let shieldedBalance = environment.SDKSynchronizer.latestScannedSynchronizerState?.shieldedBalance {
                state.shieldedBalance = shieldedBalance
            }
            if let transparentBalance = environment.SDKSynchronizer.latestScannedSynchronizerState?.transparentBalance {
                state.transparentBalance = transparentBalance
            }
            return Effect(value: .updateLatestBlock)
            
        case .updateLatestBlock:
            guard let latestBlockNumber = environment.SDKSynchronizer.latestScannedSynchronizerState?.latestScannedHeight,
            let latestBlock = environment.numberFormatter.string(NSDecimalNumber(value: latestBlockNumber)) else {
                state.latestBlock = "unknown"
                return .none
            }
            state.latestBlock = "\(latestBlock)"
            return .none
        }
    }
}

// MARK: - Placeholders

extension BalanceBreakdownState {
    static let placeholder = BalanceBreakdownState(
        autoShieldingTreshold: Zatoshi(1_000_000),
        latestBlock: "unknown",
        shieldedBalance: WalletBalance.zero,
        transparentBalance: WalletBalance.zero
    )
}

extension BalanceBreakdownStore {
    static let placeholder = BalanceBreakdownStore(
        initialState: .placeholder,
        reducer: .default,
        environment: .live
    )
}
