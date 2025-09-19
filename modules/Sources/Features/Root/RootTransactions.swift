//
//  RootTransactions.swift
//  modules
//
//  Created by Lukáš Korba on 29.01.2025.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Generated
import Models
import UserMetadataProvider

extension Root {
    public func transactionsReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .observeTransactions:
                return .merge(
                    .publisher {
                        sdkSynchronizer.eventStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .compactMap {
                                if case SynchronizerEvent.foundTransactions(let transactions, _) = $0 {
                                    return Root.Action.foundTransactions(transactions)
                                } else if case SynchronizerEvent.minedTransaction(let transaction) = $0 {
                                    return Root.Action.minedTransaction(transaction)
                                }
                                return nil
                            }
                    }
                    .cancellable(id: state.CancelEventId, cancelInFlight: true),
                    .publisher {
                        sdkSynchronizer.stateStream()
                            .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                            .map {
                                if $0.syncStatus == .upToDate {
                                    return Root.Action.fetchTransactionsForTheSelectedAccount
                                }
                                return Root.Action.noChangeInTransactions
                            }
                    }
                    .cancellable(id: state.CancelStateId, cancelInFlight: true),
                    .send(.fetchTransactionsForTheSelectedAccount)
                )
                
            case .noChangeInTransactions:
                return .none
                
            case .foundTransactions:
                return .send(.fetchTransactionsForTheSelectedAccount)
                
            case .minedTransaction:
                return .send(.fetchTransactionsForTheSelectedAccount)

            case .fetchTransactionsForTheSelectedAccount:
                guard let accountUUID = state.selectedWalletAccount?.id else {
                    return .none
                }
                return .run { send in
                    if let transactions = try? await sdkSynchronizer.getAllTransactions(accountUUID) {
                        await send(.fetchedTransactions(transactions))
                    }
                }
                
            case .fetchedTransactions(let transactions):
                let mempoolHeight = sdkSynchronizer.latestState().latestBlockHeight + 1
                
                // swaps to zec
                var mixedTransactions = transactions

                let allSwaps: [UMSwapId] = userMetadataProvider.allSwaps().filter {
                    // TODO: make it without hardcoded value
                    $0.provider == "near.zec.zec"
                }

                allSwaps.forEach { swap in
                    mixedTransactions.append(
                        TransactionState(
                            depositAddress: swap.depositAddress,
                            timestamp: TimeInterval(swap.lastUpdated / 1000),
                            zecAmount: swap.totalUSDFees.isEmpty ? nil : swap.totalUSDFees
                        )
                    )
                }

                let sortedTransactions = mixedTransactions
                    .sorted { lhs, rhs in
                        if let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp {
                            return lhsTimestamp > rhsTimestamp
                        } else {
                            return lhs.transactionListHeight(mempoolHeight) > rhs.transactionListHeight(mempoolHeight)
                        }
                    }
                
                let identifiedArray = IdentifiedArrayOf<TransactionState>(uniqueElements: sortedTransactions)
                
                if state.transactions != identifiedArray {
                    state.$transactions.withLock {
                        $0 = identifiedArray
                    }
                }
                return .none

            default: return .none
            }
        }
    }
}
