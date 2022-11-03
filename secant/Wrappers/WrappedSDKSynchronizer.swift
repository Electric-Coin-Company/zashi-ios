//
//  WrappedSDKSynchronizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.04.2022.
//

import Foundation
import ZcashLightClientKit
import Combine
import ComposableArchitecture

enum WrappedSDKSynchronizerState: Equatable {
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

enum WrappedSDKSynchronizerError: Error {
    case synchronizedNotInitialized
}

protocol WrappedSDKSynchronizer {
    var blockProcessor: CompactBlockProcessor? { get }
    var notificationCenter: WrappedNotificationCenter { get }
    var synchronizer: SDKSynchronizer? { get }
    var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never> { get }
    var walletBirthday: BlockHeight? { get }
    var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState? { get }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) async throws
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

    func getTransparentAddress(account: Int) async -> TransparentAddress?
    func getSaplingAddress(account: Int) async -> SaplingAddress?
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: String?
    ) -> Effect<Result<TransactionState, NSError>, Never>
}

extension WrappedSDKSynchronizer {
    func start() throws {
        try start(retry: false)
    }

    func getTransparentAddress() async -> TransparentAddress? {
        await getTransparentAddress(account: 0)
    }

    func getSaplingAddress() async -> SaplingAddress? {
        await getSaplingAddress(account: 0)
    }
}

class LiveWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private var cancellables: [AnyCancellable] = []
    private(set) var blockProcessor: CompactBlockProcessor?
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var notificationCenter: WrappedNotificationCenter
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: WrappedNotificationCenter = .live) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) async throws {
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

        guard try await synchronizer.prepare(with: seedBytes) == .success else {
            throw SynchronizerError.initFailed(message: "")
        }

        blockProcessor = synchronizer.blockProcessor
        walletBirthday = initializer.walletBirthday

        self.synchronizer = synchronizer
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
        stop()
        
        var height: BlockHeight?
        
        switch policy {
        case .quick, .transaction:
            break
            
        case .birthday:
            height = walletBirthday
            
        case .height(let blockheight):
            height = blockheight
        }
        
        do {
            _ = try await blockProcessor?.rewindTo(height)
        } catch {
            throw SynchronizerError.rewindError(underlyingError: error)
        }
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

    func getTransparentAddress(account: Int) async -> TransparentAddress? {
        await synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getSaplingAddress(account: Int) async -> SaplingAddress? {
        await synchronizer?.getSaplingAddress(accountIndex: account)
    }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: String?
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        return Effect.run { [weak self] send in
            do {
                guard let synchronizer = self?.synchronizer else {
                    await send(.failure(WrappedSDKSynchronizerError.synchronizedNotInitialized as NSError))
                    return
                }

                let finalMemo: Memo?
                if let memoText = memo {
                    finalMemo = try Memo(string: memoText)
                } else {
                    finalMemo = nil
                }

                let pendingTransaction = try await synchronizer.sendToAddress(
                    spendingKey: spendingKey,
                    zatoshi: zatoshi,
                    toAddress: recipientAddress,
                    memo: finalMemo
                )

                await send(.success(TransactionState(pendingTransaction: pendingTransaction)))
            } catch {
                await send(.failure(error as NSError))
            }
        }
    }
}

class MockWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private var cancellables: [AnyCancellable] = []
    private(set) var blockProcessor: CompactBlockProcessor?
    private(set) var notificationCenter: WrappedNotificationCenter
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: WrappedNotificationCenter = .mock) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) async throws {
        _ = try await synchronizer?.prepare(with: seedBytes)
    }

    func start(retry: Bool) throws {
        try synchronizer?.start(retry: retry)
    }

    func stop() {
        synchronizer?.stop()
    }

    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) {
        stateChanged.send(.synced)
    }

    func statusSnapshot() -> SyncStatusSnapshot {
        guard let synchronizer = synchronizer else {
            return .default
        }
        
        return SyncStatusSnapshot.snapshotFor(state: synchronizer.status)
    }

    func rewind(_ policy: RewindPolicy) throws { }
    
    func getShieldedBalance() -> WalletBalance? {
        WalletBalance(verified: Zatoshi(12345000), total: Zatoshi(12345000))
    }

    func getTransparentBalance() -> WalletBalance? {
        WalletBalance(verified: Zatoshi(12345000), total: Zatoshi(12345000))
    }

    func getAllClearedTransactions() -> Effect<[WalletEvent], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "2"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "3"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "4"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "5")
        ]
        
        return Effect(
            value:
                mocked.map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.status,
                        timestamp: $0.date,
                        uuid: $0.uuid
                    )
                    return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                }
        )
    }

    func getAllPendingTransactions() -> Effect<[WalletEvent], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039606, amount: Zatoshi(6), status: .paid(success: false)),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(7)),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(8), status: .paid(success: true)),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(9))
        ]
        
        return Effect(
            value:
                mocked.map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.status,
                        timestamp: $0.date
                    )
                    return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
                }
        )
    }

    func getAllTransactions() -> Effect<[WalletEvent], Never> {
        return .merge(
            getAllClearedTransactions(),
            getAllPendingTransactions()
        )
        .flatMap(Publishers.Sequence.init(sequence:))
        .collect()
        .eraseToEffect()
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getSaplingAddress(account: Int) -> SaplingAddress? { nil }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: String?
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        let transactionState = TransactionState(
            expirationHeight: 40,
            memo: memo,
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            fee: Zatoshi(10),
            id: "id",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(10)
        )

        return Effect.run { send in
            await send(.success(transactionState))
        }
    }
}

class TestWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private(set) var blockProcessor: CompactBlockProcessor?
    private(set) var notificationCenter: WrappedNotificationCenter
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: WrappedNotificationCenter = .mock) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) { }

    func statusSnapshot() -> SyncStatusSnapshot { .default }

    func rewind(_ policy: RewindPolicy) throws { }
    
    func getShieldedBalance() -> WalletBalance? { nil }
    
    func getTransparentBalance() -> WalletBalance? { nil }

    func getAllClearedTransactions() -> Effect<[WalletEvent], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55")
        ]
        
        return Effect(
            value:
                mocked.map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.status,
                        timestamp: $0.date,
                        uuid: $0.uuid
                    )
                    return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
                }
        )
    }

    func getAllPendingTransactions() -> Effect<[WalletEvent], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(
                date: 1651039606,
                amount: Zatoshi(6),
                status: .paid(success: false),
                uuid: "ff66"
            ),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(7), uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(8), status: .paid(success: true), uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(9), uuid: "ii99")
        ]
        
        return Effect(
            value:
                mocked.map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.amount.amount > 5 ? .pending : $0.status,
                        timestamp: $0.date,
                        uuid: $0.uuid
                    )
                    return WalletEvent(id: transaction.id, state: .pending(transaction), timestamp: transaction.timestamp)
                }
        )
    }

    func getAllTransactions() -> Effect<[WalletEvent], Never> {
        return .merge(
            getAllClearedTransactions(),
            getAllPendingTransactions()
        )
        .flatMap(Publishers.Sequence.init(sequence:))
        .collect()
        .eraseToEffect()
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getSaplingAddress(account: Int) -> SaplingAddress? {
        // swiftlint:disable:next force_try
        try! SaplingAddress(encoding: "ztestsapling1edm52k336nk70gxqxedd89slrrf5xwnnp5rt6gqnk0tgw4mynv6fcx42ym6x27yac5amvfvwypz", network: .testnet)
    }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: String?
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        return Effect.run { send in
            await send(.failure(SynchronizerError.criticalError as NSError))
        }
    }
    
    func updateStateChanged(_ newState: WrappedSDKSynchronizerState) {
        stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(newState)
    }
}
