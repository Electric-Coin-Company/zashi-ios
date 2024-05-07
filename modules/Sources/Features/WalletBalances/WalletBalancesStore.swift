//
//  WalletBalancesStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04-02-2024
//

import Foundation
import ComposableArchitecture

import Models
import SDKSynchronizer
import Utils
import ZcashLightClientKit

@Reducer
public struct WalletBalances {
    private let CancelStateId = UUID()

    @ObservableState
    public struct State: Equatable {
        public var isAvailableBalanceTappable = true
        public var migratingDatabase = false
        public var shieldedBalance: Zatoshi
        public var shieldedWithPendingBalance: Zatoshi
        public var totalBalance: Zatoshi
        public var transparentBalance: Zatoshi

        public var isProcessingZeroAvailableBalance: Bool {
            if shieldedBalance.amount == 0 && transparentBalance.amount > 0 {
                return false
            }
            
            return totalBalance.amount != shieldedBalance.amount && shieldedBalance.amount == 0
        }

        public init(
            isAvailableBalanceTappable: Bool = true,
            migratingDatabase: Bool = false,
            shieldedBalance: Zatoshi = .zero,
            shieldedWithPendingBalance: Zatoshi = .zero,
            totalBalance: Zatoshi = .zero,
            transparentBalance: Zatoshi = .zero
        ) {
            self.isAvailableBalanceTappable = isAvailableBalanceTappable
            self.migratingDatabase = migratingDatabase
            self.shieldedBalance = shieldedBalance
            self.shieldedWithPendingBalance = shieldedWithPendingBalance
            self.totalBalance = totalBalance
            self.transparentBalance = transparentBalance
        }
    }
    
    public enum Action: Equatable {
        case availableBalanceTapped
        case balancesUpdated(AccountBalance?)
        case debugMenuStartup
        case onAppear
        case onDisappear
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateBalances
    }

    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.updateBalances),
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map { $0.redacted }
                            .map(WalletBalances.Action.synchronizerStateChanged)
                    }
                    .cancellable(id: CancelStateId, cancelInFlight: true)
                )

            case .onDisappear:
                return .cancel(id: CancelStateId)
                
            case .availableBalanceTapped:
                return .none

            case .updateBalances:
                return .run { send in
                    if let accountBalance = try? await sdkSynchronizer.getAccountBalance(0) {
                        await send(.balancesUpdated(accountBalance))
                    } else if let accountBalance = sdkSynchronizer.latestState().accountBalance {
                        await send(.balancesUpdated(accountBalance))
                    }
                }
                
            case .balancesUpdated(let accountBalance):
                state.shieldedBalance = (accountBalance?.saplingBalance.spendableValue ?? .zero) + (accountBalance?.orchardBalance.spendableValue ?? .zero)
                state.shieldedWithPendingBalance = (accountBalance?.saplingBalance.total() ?? .zero) + (accountBalance?.orchardBalance.total() ?? .zero)
                state.transparentBalance = accountBalance?.unshielded ?? .zero
                state.totalBalance = state.shieldedWithPendingBalance + state.transparentBalance
                return .none

            case .debugMenuStartup:
                return .none
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)

                if snapshot.syncStatus != .unprepared {
                    state.migratingDatabase = false
                }

                return .send(.balancesUpdated(latestState.data.accountBalance?.data))
            }
        }
    }
}
