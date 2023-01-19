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

enum SDKSynchronizerDependency: DependencyKey {
    static let liveValue: SDKSynchronizerClient = LiveSDKSynchronizerClient()
}

class LiveSDKSynchronizerClient: SDKSynchronizerClient {
    private var cancellables: [AnyCancellable] = []
    private(set) var synchronizer: SDKSynchronizer?
    // TODO: [#497] Since 0.17.0-beta SDKSynchronizer has `lastState` property which does exactly the same as `stateChanged`. Problem is that we have
    // synchronizer as optional. And now it would be complicated to handle the situation when `lastState` isn't always available. Let's handle this
    // in future.
    private(set) var stateChanged: CurrentValueSubject<SDKSynchronizerState, Never>
    private(set) var notificationCenter: NotificationCenterClient
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: NotificationCenterClient = .live) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) throws {
        let synchronizer = try SDKSynchronizer(initializer: initializer)

        notificationCenter.publisherFor(.synchronizerStarted)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerStarted() }
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

        guard try synchronizer.prepare(with: seedBytes) == .success else {
            throw SynchronizerError.initFailed(message: "")
        }

        self.synchronizer = synchronizer
        walletBirthday = initializer.walletBirthday
    }
    
    func start(retry: Bool) throws {
        try synchronizer?.start(retry: retry)
    }

    func stop() {
        synchronizer?.stop()
    }

    func synchronizerStarted() {
        stateChanged.send(.started)
    }

    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) {
        stateChanged.send(.synced)
        latestScannedSynchronizerState = synchronizerState
    }

    func synchronizerProgressUpdated() {
        stateChanged.send(.progressUpdated)
    }

    func synchronizerStopped() {
        stateChanged.send(.stopped)
    }

    func statusSnapshot() -> SyncStatusSnapshot {
        guard let synchronizer = synchronizer else {
            return .default
        }
        
        return SyncStatusSnapshot.snapshotFor(state: synchronizer.status)
    }

    func rewind(_ policy: RewindPolicy) async throws {
        try await synchronizer?.rewind(policy)
    }
    
    func getShieldedBalance() -> WalletBalance? {
        latestScannedSynchronizerState?.shieldedBalance
    }

    func getTransparentBalance() -> WalletBalance? {
        latestScannedSynchronizerState?.transparentBalance
    }

    func getAllClearedTransactions() -> Effect<[WalletEvent], Never> {
        if let clearedTransactions = try? synchronizer?.allClearedTransactions() {
            return Effect(value: clearedTransactions.map {
                let transaction = TransactionState.init(confirmedTransaction: $0, sent: ($0.toAddress != nil))
                return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
            })
        }
        
        return .none
    }
    
    func getAllPendingTransactions() -> Effect<[WalletEvent], Never> {
        if let pendingTransactions = try? synchronizer?.allPendingTransactions(),
        let syncedBlockHeight = synchronizer?.latestScannedHeight {
            return Effect(value: pendingTransactions.map {
                let transaction = TransactionState.init(pendingTransaction: $0, latestBlockHeight: syncedBlockHeight)
                return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
            })
        }
        
        return .none
    }

    func getAllTransactions() -> Effect<[WalletEvent], Never> {
        if let pendingTransactions = try? synchronizer?.allPendingTransactions(),
        let clearedTransactions = try? synchronizer?.allClearedTransactions(),
        let syncedBlockHeight = synchronizer?.latestScannedHeight {
            let clearedTxs: [WalletEvent] = clearedTransactions.map {
                let transaction = TransactionState.init(confirmedTransaction: $0, sent: ($0.toAddress != nil))
                return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
            }
            let pendingTxs: [WalletEvent] = pendingTransactions.map {
                let transaction = TransactionState.init(pendingTransaction: $0, latestBlockHeight: syncedBlockHeight)
                return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
            }
            
            let txs = clearedTxs.filter { cleared in
                pendingTxs.first { pending in
                    pending.id == cleared.id
                } == nil
            }
            return .merge(
                Effect(value: txs),
                Effect(value: pendingTxs)
            )
            .flatMap(Publishers.Sequence.init(sequence:))
            .collect()
            .eraseToEffect()
        }
        
        return .none
    }

    func getUnifiedAddress(account: Int) -> UnifiedAddress? {
        synchronizer?.getUnifiedAddress(accountIndex: account)
    }
    
    func getTransparentAddress(account: Int) -> TransparentAddress? {
        synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getSaplingAddress(accountIndex: Int) async -> SaplingAddress? {
        await synchronizer?.getSaplingAddress(accountIndex: accountIndex)
    }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        return Effect.run { [weak self] send in
            do {
                guard let synchronizer = self?.synchronizer else {
                    await send(.failure(SDKSynchronizerClientError.synchronizerNotInitialized as NSError))
                    return
                }

                let pendingTransaction = try await synchronizer.sendToAddress(
                    spendingKey: spendingKey,
                    zatoshi: zatoshi,
                    toAddress: recipientAddress,
                    memo: memo
                )

                await send(.success(TransactionState(pendingTransaction: pendingTransaction)))
            } catch {
                await send(.failure(error as NSError))
            }
        }
    }
}
