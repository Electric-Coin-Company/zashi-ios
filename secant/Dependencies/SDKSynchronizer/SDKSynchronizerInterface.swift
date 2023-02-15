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
    case progressUpdated
    case started
    case stopped
    case synced
    case unknown
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
    func isSyncing() -> Bool
    func isInitialized() -> Bool

    func rewind(_ policy: RewindPolicy) async throws

    func getShieldedBalance() -> WalletBalance?
    func getTransparentBalance() -> WalletBalance?
    func getAllSentTransactions() -> EffectTask<[WalletEvent]>
    func getAllReceivedTransactions() -> EffectTask<[WalletEvent]>
    func getAllClearedTransactions() -> EffectTask<[WalletEvent]>
    func getAllPendingTransactions() -> EffectTask<[WalletEvent]>
    func getAllTransactions() -> EffectTask<[WalletEvent]>

    func getUnifiedAddress(account: Int) -> UnifiedAddress?
    func getTransparentAddress(account: Int) -> TransparentAddress?
    func getSaplingAddress(accountIndex: Int) async -> SaplingAddress?
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) -> EffectTask<Result<TransactionState, NSError>>
    
    func wipe() -> AnyPublisher<Void, Error>?
}

extension SDKSynchronizerClient {
    func start() throws {
        try start(retry: false)
    }
}
