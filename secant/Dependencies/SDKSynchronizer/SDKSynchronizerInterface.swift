//
//  SDKSynchronizerClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.04.2022.
//

import Foundation
import Combine
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    var sdkSynchronizer: SDKSynchronizerClient {
        get { self[SDKSynchronizerDependency.self] }
        set { self[SDKSynchronizerDependency.self] = newValue }
    }
}

enum SDKSynchronizerState: Equatable {
    case unknown
    case transactionsUpdated
    case started
    case progressUpdated
    case statusWillUpdate
    case synced
    case stopped
    case disconnected
    case syncing
    case downloading
    case validating
    case scanning
    case enhancing
    case fetching
    case minedTransaction
    case foundTransactions
    case failed
    case connectionStateChanged
}

enum SDKSynchronizerClientError: Error {
    case synchronizerNotInitialized
}

protocol SDKSynchronizerClient {
    var notificationCenter: NotificationCenterClient { get }
    var synchronizer: SDKSynchronizer? { get }
    var stateChanged: CurrentValueSubject<SDKSynchronizerState, Never> { get }
    var walletBirthday: BlockHeight? { get }
    var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState? { get }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) throws
    func start(retry: Bool) throws
    func stop()
    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?)
    func statusSnapshot() -> SyncStatusSnapshot

    func rewind(_ policy: RewindPolicy) async throws

    func getShieldedBalance() -> WalletBalance?
    func getTransparentBalance() -> WalletBalance?
    func getAllClearedTransactions() -> Effect<[WalletEvent], Never>
    func getAllPendingTransactions() -> Effect<[WalletEvent], Never>
    func getAllTransactions() -> Effect<[WalletEvent], Never>

    func getUnifiedAddress(account: Int) -> UnifiedAddress?
    func getTransparentAddress(account: Int) -> TransparentAddress?
    func getSaplingAddress(accountIndex: Int) async -> SaplingAddress?
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) -> Effect<Result<TransactionState, NSError>, Never>
}

extension SDKSynchronizerClient {
    func start() throws {
        try start(retry: false)
    }
}
