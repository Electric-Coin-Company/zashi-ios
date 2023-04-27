//
//  SDKSynchronizerLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import Combine
import ComposableArchitecture
import ZcashLightClientKit

extension SDKSynchronizerClient: DependencyKey {
    static let liveValue: SDKSynchronizerClient = Self.live()

    static func live(
        databaseFiles: DatabaseFilesClient = .liveValue,
        environment: ZcashSDKEnvironment = .liveValue
    ) -> Self {
        let network = environment.network
        let initializer = Initializer(
            cacheDbURL: databaseFiles.cacheDbURLFor(network),
            fsBlockDbRoot: databaseFiles.fsBlockDbRootFor(network),
            dataDbURL: databaseFiles.dataDbURLFor(network),
            pendingDbURL: databaseFiles.pendingDbURLFor(network),
            endpoint: environment.endpoint,
            network: network,
            spendParamsURL: databaseFiles.spendParamsURLFor(network),
            outputParamsURL: databaseFiles.outputParamsURLFor(network),
            saplingParamsSourceURL: SaplingParamsSourceURL.default,
            logLevel: .debug
        )
        
        let synchronizer = SDKSynchronizer(initializer: initializer)

        return SDKSynchronizerClient(
            stateStream: { synchronizer.stateStream },
            eventStream: { synchronizer.eventStream },
            latestState: { synchronizer.latestState },
            latestScannedHeight: { synchronizer.latestState.latestScannedHeight },
            prepareWith: { seedBytes, viewingKey, walletBirtday in
                let result = try await synchronizer.prepare(with: seedBytes, viewingKeys: [viewingKey], walletBirthday: walletBirtday)
                if result != .success { throw ZcashError.synchronizerNotPrepared }
            },
            start: { retry in try await synchronizer.start(retry: retry) },
            stop: { await synchronizer.stop() },
            isSyncing: { synchronizer.latestState.syncStatus.isSyncing },
            isInitialized: { synchronizer.latestState.syncStatus != .unprepared },
            rewind: { synchronizer.rewind($0) },
            getShieldedBalance: { synchronizer.latestState.shieldedBalance },
            getTransparentBalance: { synchronizer.latestState.transparentBalance },
            getAllTransactions: {
                let pendingTransactions = try await synchronizer.allPendingTransactions()
                let clearedTransactions = try await synchronizer.allClearedTransactions()

                var clearedTxs: [WalletEvent] = []
                for clearedTransaction in clearedTransactions {
                    var transaction = TransactionState.init(
                        transaction: clearedTransaction,
                        memos: clearedTransaction.memoCount > 0 ? try await synchronizer.getMemos(for: clearedTransaction) : nil
                    )

                    let recipients = await synchronizer.getRecipients(for: clearedTransaction)
                    let addresses = recipients.compactMap {
                        if case let .address(address) = $0 {
                            return address
                        } else {
                            return nil
                        }
                    }
                    
                    transaction.zAddress = addresses.first?.stringEncoded
                    
                    clearedTxs.append(
                        WalletEvent(
                            id: transaction.id,
                            state: clearedTransaction.isSentTransaction ? .sent(transaction) : .received(transaction),
                            timestamp: transaction.timestamp
                        )
                    )
                }
                
                let pendingTxs: [WalletEvent] = pendingTransactions.map {
                    let transaction = TransactionState.init(pendingTransaction: $0, latestBlockHeight: synchronizer.latestState.latestScannedHeight)
                    return WalletEvent(
                        id: transaction.id,
                        state: .pending(transaction),
                        timestamp: transaction.timestamp
                    )
                }
                
                var cTxs = clearedTxs.filter { transaction in
                    pendingTxs.first { pending in
                        pending.id == transaction.id
                    } == nil
                }
                cTxs.append(contentsOf: pendingTxs)
                
                return cTxs
            },
            getUnifiedAddress: { try await synchronizer.getUnifiedAddress(accountIndex: $0) },
            getTransparentAddress: { try await synchronizer.getTransparentAddress(accountIndex: $0) },
            getSaplingAddress: { try await synchronizer.getSaplingAddress(accountIndex: $0) },
            sendTransaction: { spendingKey, amount, recipient, memo in
                return .run { send in
                    do {
                        let pendingTransaction = try await synchronizer.sendToAddress(
                            spendingKey: spendingKey,
                            zatoshi: amount,
                            toAddress: recipient,
                            memo: memo
                        )

                        await send(.success(TransactionState(pendingTransaction: pendingTransaction)))
                    } catch {
                        await send(.failure(error as NSError))
                    }
                }
            },
            shieldFunds: { spendingKey, memo, shieldingThreshold in
                let pendingTransaction = try await synchronizer.shieldFunds(
                    spendingKey: spendingKey,
                    memo: memo,
                    shieldingThreshold: shieldingThreshold
                )
                return TransactionState(pendingTransaction: pendingTransaction)
            },
            wipe: { synchronizer.wipe() }
        )
    }
}
