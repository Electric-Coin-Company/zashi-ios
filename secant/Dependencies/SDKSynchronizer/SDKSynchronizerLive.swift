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
            loggerProxy: OSLogger(logLevel: .debug, category: LoggerConstants.sdkLogs)
        )
        
        let synchronizer = SDKSynchronizer(initializer: initializer)

        return SDKSynchronizerClient(
            stateStream: { synchronizer.stateStream },
            eventStream: { synchronizer.eventStream },
            latestState: { synchronizer.latestState },
            latestScannedHeight: { synchronizer.latestScannedHeight },
            prepareWith: { seedBytes, viewingKey, walletBirtday in
                let result = try await synchronizer.prepare(with: seedBytes, viewingKeys: [viewingKey], walletBirthday: walletBirtday)

                if result != .success {
                    throw SynchronizerError.initFailed(message: "")
                }
            },
            start: { retry in try await synchronizer.start(retry: retry) },
            stop: { await synchronizer.stop() },
            isSyncing: { synchronizer.latestState.syncStatus.isSyncing },
            isInitialized: { synchronizer.latestState.syncStatus != .unprepared },
            rewind: { synchronizer.rewind($0) },
            getShieldedBalance: { synchronizer.latestState.shieldedBalance },
            getTransparentBalance: { synchronizer.latestState.transparentBalance },
            getAllSentTransactions: {
                if let transactions = try? synchronizer.allSentTransactions() {
                    return EffectTask(value: transactions.map {
                        let memos = try? synchronizer.getMemos(for: $0)
                        let transaction = TransactionState.init(transaction: $0, memos: memos)
                        return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                    })
                }

                return .none
            },
            getAllReceivedTransactions: {
                if let transactions = try? synchronizer.allReceivedTransactions() {
                    return EffectTask(value: transactions.map {
                        let memos = try? synchronizer.getMemos(for: $0)
                        let transaction = TransactionState.init(transaction: $0, memos: memos)
                        return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                    })
                }

                return .none
            },
            getAllClearedTransactions: {
                if let transactions = try? synchronizer.allClearedTransactions() {
                    return EffectTask(value: transactions.map {
                        let memos = try? synchronizer.getMemos(for: $0)
                        let transaction = TransactionState.init(transaction: $0, memos: memos)
                        return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                    })
                }

                return .none
            },
            getAllPendingTransactions: {
                if let transactions = try? synchronizer.allPendingTransactions() {
                    return EffectTask(value: transactions.map {
                        let transaction = TransactionState.init(pendingTransaction: $0, latestBlockHeight: synchronizer.latestScannedHeight)
                        return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
                    })
                }

                return .none
            },
            getAllTransactions: {
                if  let pendingTransactions = try? synchronizer.allPendingTransactions(),
                    let clearedTransactions = try? synchronizer.allClearedTransactions() {
                    let clearedTxs: [WalletEvent] = clearedTransactions.map {
                        let transaction = TransactionState.init(transaction: $0)
                        return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                    }
                    let pendingTxs: [WalletEvent] = pendingTransactions.map {
                        let transaction = TransactionState.init(pendingTransaction: $0, latestBlockHeight: synchronizer.latestScannedHeight)
                        return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
                    }
                    let cTxs = clearedTxs.filter { transaction in
                        pendingTxs.first { pending in
                            pending.id == transaction.id
                        } == nil
                    }

                    return .merge(
                        EffectTask(value: cTxs),
                        EffectTask(value: pendingTxs)
                    )
                    .flatMap(Publishers.Sequence.init(sequence:))
                    .collect()
                    .eraseToEffect()
                }

                return .none
            },
            getUnifiedAddress: { synchronizer.getUnifiedAddress(accountIndex: $0) },
            getTransparentAddress: { synchronizer.getTransparentAddress(accountIndex: $0) },
            getSaplingAddress: { await synchronizer.getSaplingAddress(accountIndex: $0) },
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
