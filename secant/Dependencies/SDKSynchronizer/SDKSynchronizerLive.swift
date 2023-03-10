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

private class SDKSynchronizerLiveWrapper {
    private var cancellables: [AnyCancellable] = []
    let synchronizer: SDKSynchronizer
    let stateChanged: CurrentValueSubject<SDKSynchronizerState, Never>
    var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(
        notificationCenter: NotificationCenterClient = .live,
        databaseFiles: DatabaseFilesClient = .liveValue,
        environment: ZcashSDKEnvironment = .liveValue
    ) {
        self.stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(.unknown)

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

        synchronizer = SDKSynchronizer(initializer: initializer)
        subscribeToNotifications(notificationCenter: notificationCenter)
    }

    deinit {
        synchronizer.stop()
    }

    private func subscribeToNotifications(notificationCenter: NotificationCenterClient) {
        notificationCenter.publisherFor(.synchronizerStarted)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notif in
                let synchronizerState = notif.userInfo?[SDKSynchronizer.NotificationKeys.synchronizerState] as? SDKSynchronizer.SynchronizerState
                self?.synchronizerStarted(synchronizerState)
            }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerSynced)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                let synchronizerState = output.userInfo?[SDKSynchronizer.NotificationKeys.synchronizerState] as? SDKSynchronizer.SynchronizerState
                self?.synchronizerSynced(synchronizerState)
            }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerProgressUpdated)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerProgressUpdated() }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerStopped)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerStopped() }
            .store(in: &cancellables)
    }

    private func synchronizerStarted(_ synchronizerState: SDKSynchronizer.SynchronizerState?) {
        latestScannedSynchronizerState = synchronizerState
        stateChanged.send(.started)
    }

    private func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) {
        latestScannedSynchronizerState = synchronizerState
        stateChanged.send(.synced)
    }

    private func synchronizerProgressUpdated() {
        stateChanged.send(.progressUpdated)
    }

    private func synchronizerStopped() {
        stateChanged.send(.stopped)
    }
}

extension SDKSynchronizerClient: DependencyKey {
    static let liveValue: SDKSynchronizerClient = Self.live()

    static func live(
        notificationCenter: NotificationCenterClient = .live,
        databaseFiles: DatabaseFilesClient = .liveValue,
        environment: ZcashSDKEnvironment = .liveValue
    ) -> Self {
        let sdkSynchronizerWrapper = SDKSynchronizerLiveWrapper(
            notificationCenter: notificationCenter,
            databaseFiles: databaseFiles,
            environment: environment
        )
        let synchronizer = sdkSynchronizerWrapper.synchronizer

        return SDKSynchronizerClient(
            stateChangedStream: { sdkSynchronizerWrapper.stateChanged },
            latestScannedSynchronizerState: { sdkSynchronizerWrapper.latestScannedSynchronizerState },
            latestScannedHeight: { synchronizer.latestScannedHeight },
            prepareWith: { seedBytes, viewingKey, walletBirtday in
                let result = try synchronizer.prepare(with: seedBytes, viewingKeys: [viewingKey], walletBirthday: walletBirtday)

                if result != .success {
                    throw SynchronizerError.initFailed(message: "")
                }
            },
            start: { retry in try synchronizer.start(retry: retry) },
            stop: { synchronizer.stop() },
            statusSnapshot: { SyncStatusSnapshot.snapshotFor(state: synchronizer.status) },
            isSyncing: { sdkSynchronizerWrapper.latestScannedSynchronizerState?.syncStatus.isSyncing ?? false },
            isInitialized: { synchronizer.status != .unprepared },
            rewind: { synchronizer.rewind($0) },
            getShieldedBalance: { sdkSynchronizerWrapper.latestScannedSynchronizerState?.shieldedBalance },
            getTransparentBalance: { sdkSynchronizerWrapper.latestScannedSynchronizerState?.transparentBalance },
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
