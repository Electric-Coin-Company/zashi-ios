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
import DatabaseFiles
import Models
import ZcashSDKEnvironment

extension SDKSynchronizerClient: DependencyKey {
    public static let liveValue: SDKSynchronizerClient = Self.live()
    
    public static func live(
        databaseFiles: DatabaseFilesClient = .liveValue
    ) -> Self {
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
        
        let network = zcashSDKEnvironment.network
        
        #if DEBUG
        let loggingPolicy = Initializer.LoggingPolicy.default(.debug)
        #else
        let loggingPolicy = Initializer.LoggingPolicy.noLogging
        #endif
        
        let initializer = Initializer(
            cacheDbURL: databaseFiles.cacheDbURLFor(network),
            fsBlockDbRoot: databaseFiles.fsBlockDbRootFor(network),
            generalStorageURL: databaseFiles.documentsDirectory(),
            dataDbURL: databaseFiles.dataDbURLFor(network),
            torDirURL: databaseFiles.toDirURLFor(network),
            endpoint: zcashSDKEnvironment.endpoint(),
            network: network,
            spendParamsURL: databaseFiles.spendParamsURLFor(network),
            outputParamsURL: databaseFiles.outputParamsURLFor(network),
            saplingParamsSourceURL: SaplingParamsSourceURL.default,
            loggingPolicy: loggingPolicy
        )
        
        let synchronizer = SDKSynchronizer(initializer: initializer)

        return SDKSynchronizerClient(
            stateStream: { synchronizer.stateStream },
            eventStream: { synchronizer.eventStream },
            exchangeRateUSDStream: { synchronizer.exchangeRateUSDStream },
            latestState: { synchronizer.latestState },
            prepareWith: { seedBytes, walletBirtday, walletMode in
                let result = try await synchronizer.prepare(with: seedBytes, walletBirthday: walletBirtday, for: walletMode)
                if result != .success { throw ZcashError.synchronizerNotPrepared }
            },
            start: { retry in try await synchronizer.start(retry: retry) },
            stop: { synchronizer.stop() },
            isSyncing: { synchronizer.latestState.syncStatus.isSyncing },
            isInitialized: { synchronizer.latestState.syncStatus != SyncStatus.unprepared },
            rewind: { synchronizer.rewind($0) },
            getAllTransactions: {
                let clearedTransactions = try await synchronizer.allTransactions()

                var clearedTxs: [TransactionState] = []
                
                let latestBlockHeight = try await SDKSynchronizerClient.latestBlockHeight(synchronizer: synchronizer)
                
                for clearedTransaction in clearedTransactions {
                    var hasTransparentOutputs = false
                    let outputs = await synchronizer.getTransactionOutputs(for: clearedTransaction)
                    for output in outputs {
                        if case .transaparent = output.pool {
                            hasTransparentOutputs = true
                            break
                        }
                    }

                    var transaction = TransactionState.init(
                        transaction: clearedTransaction,
                        memos: nil,
                        hasTransparentOutputs: hasTransparentOutputs,
                        latestBlockHeight: latestBlockHeight
                    )

                    let recipients = await synchronizer.getRecipients(for: clearedTransaction)
                    let addresses = recipients.compactMap {
                        if case let .address(address) = $0 {
                            return address
                        } else {
                            return nil
                        }
                    }
                    
                    transaction.rawID = clearedTransaction.rawID
                    transaction.zAddress = addresses.first?.stringEncoded
                    if let someAddress = addresses.first, case .transparent = someAddress {
                        transaction.isTransparentRecipient = true
                    }
                    
                    clearedTxs.append(transaction)
                }

                return clearedTxs
            },
            getMemos: { try await synchronizer.getMemos(for: $0) },
            getUnifiedAddress: { try await synchronizer.getUnifiedAddress(accountIndex: $0) },
            getTransparentAddress: { try await synchronizer.getTransparentAddress(accountIndex: $0) },
            getSaplingAddress: { try await synchronizer.getSaplingAddress(accountIndex: $0) },
            getAccountBalance: { try await synchronizer.getAccountBalance(accountIndex: $0) },
            sendTransaction: { spendingKey, amount, recipient, memo in
                let pendingTransaction = try await synchronizer.sendToAddress(
                    spendingKey: spendingKey,
                    zatoshi: amount,
                    toAddress: recipient,
                    memo: memo
                )
                
                return TransactionState(
                    transaction: pendingTransaction,
                    latestBlockHeight: try await SDKSynchronizerClient.latestBlockHeight(synchronizer: synchronizer)
                )
            },
            shieldFunds: { spendingKey, memo, shieldingThreshold in
                let pendingTransaction = try await synchronizer.shieldFunds(
                    spendingKey: spendingKey,
                    memo: memo,
                    shieldingThreshold: shieldingThreshold
                )
                
                return TransactionState(
                    transaction: pendingTransaction,
                    latestBlockHeight: try await SDKSynchronizerClient.latestBlockHeight(synchronizer: synchronizer)
                )
            },
            wipe: { synchronizer.wipe() },
            switchToEndpoint: { endpoint in
                try await synchronizer.switchTo(endpoint: endpoint)
            },
            proposeTransfer: { accountIndex, recipient, amount, memo in
                try await synchronizer.proposeTransfer(
                    accountIndex: accountIndex,
                    recipient: recipient,
                    amount: amount,
                    memo: memo
                )
            },
            createProposedTransactions: { proposal, spendingKey in
                let stream = try await synchronizer.createProposedTransactions(
                    proposal: proposal,
                    spendingKey: spendingKey
                )

                let transactionCount = proposal.transactionCount()
                var successCount = 0
                var iterator = stream.makeAsyncIterator()
                
                var txIds: [String] = []
                var statuses: [String] = []
                var errCode = 0
                var errDesc = ""
                var resubmitableFailure = false
                
                for _ in 1...transactionCount {
                    if let transactionSubmitResult = try await iterator.next() {
                        switch transactionSubmitResult {
                        case .success(txId: let id):
                            successCount += 1
                            txIds.append(id.toHexStringTxId())
                            statuses.append("success")
                        case let .grpcFailure(txId: id, error: error):
                            txIds.append(id.toHexStringTxId())
                            statuses.append(error.localizedDescription)
                            resubmitableFailure = true
                        case let .submitFailure(txId: id, code: code, description: description):
                            txIds.append(id.toHexStringTxId())
                            statuses.append("code: \(code) desc: \(description)")
                            errCode = code
                            errDesc = description
                        case .notAttempted(txId: let id):
                            txIds.append(id.toHexStringTxId())
                            statuses.append("notAttempted")
                        }
                    }
                }
                
                if successCount == 0 {
                    if resubmitableFailure {
                        return .failure(txIds: txIds, code: errCode, description: errDesc)
                    } else {
                        return .grpcFailure(txIds: txIds)
                    }
                } else if successCount == transactionCount {
                    return .success(txIds: txIds)
                } else {
                    return .partial(txIds: txIds, statuses: statuses)
                }
            },
            proposeShielding: { accountIndex, shieldingThreshold, memo, transparentReceiver in
                try await synchronizer.proposeShielding(
                    accountIndex: accountIndex,
                    shieldingThreshold: shieldingThreshold,
                    memo: memo,
                    transparentReceiver: transparentReceiver
                )
            },
            isSeedRelevantToAnyDerivedAccount: { seed in
                try await synchronizer.isSeedRelevantToAnyDerivedAccount(seed: seed)
            },
            refreshExchangeRateUSD: {
                synchronizer.refreshExchangeRateUSD()
            },
            evaluateBestOf: { endpoints, latencyThreshold, fetchThreshold, nBlocks, kServers, network in
                await synchronizer.evaluateBestOf(
                    endpoints: endpoints,
                    latencyThresholdMillis: latencyThreshold,
                    fetchThresholdSeconds: fetchThreshold,
                    nBlocksToFetch: nBlocks,
                    kServers: kServers,
                    network: network
                )
            }
        )
    }
}

// TODO: [#1313] SDK improvements so a client doesn't need to determing if the transaction isPending
// https://github.com/zcash/ZcashLightClientKit/issues/1313
// Once #1313 is done, cleint will no longer need to call for a `latestHeight()`
private extension SDKSynchronizerClient {
    static func latestBlockHeight(synchronizer: SDKSynchronizer) async throws -> BlockHeight {
        let latestBlockHeight: BlockHeight
        
        if synchronizer.latestState.latestBlockHeight > 0 {
            latestBlockHeight = synchronizer.latestState.latestBlockHeight
        } else {
            latestBlockHeight = try await synchronizer.latestHeight()
        }
        
        return latestBlockHeight
    }
}
