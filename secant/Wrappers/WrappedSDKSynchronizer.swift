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

struct Balance: WalletBalance, Equatable {
    var verified: Int64
    var total: Int64
}

protocol WrappedSDKSynchronizer {
    var synchronizer: SDKSynchronizer? { get }
    var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never> { get }
    var notificationCenter: WrappedNotificationCenter { get }
    
    func prepareWith(initializer: Initializer) throws
    func start(retry: Bool) throws
    func stop()
    func status() -> String

    func getShieldedBalance() -> Effect<Balance, Never>
    func getAllClearedTransactions() -> Effect<[TransactionState], Never>
    func getAllPendingTransactions() -> Effect<[TransactionState], Never>
    func getAllTransactions() -> Effect<[TransactionState], Never>

    func getTransparentAddress(account: Int) -> TransparentAddress?
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress?
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never>
}

extension WrappedSDKSynchronizer {
    func start() throws {
        try start(retry: false)
    }

    func getTransparentAddress() -> TransparentAddress? {
        getTransparentAddress(account: 0)
    }

    func getShieldedAddress() -> SaplingShieldedAddress? {
        getShieldedAddress(account: 0)
    }
}

class LiveWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private var cancellables: [AnyCancellable] = []
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var notificationCenter: WrappedNotificationCenter

    init(notificationCenter: WrappedNotificationCenter = .live) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer) throws {
        synchronizer = try SDKSynchronizer(initializer: initializer)

        notificationCenter.publisherFor(.synchronizerStarted)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerStarted() }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerSynced)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerSynced() }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerProgressUpdated)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerProgressUpdated() }
            .store(in: &cancellables)

        notificationCenter.publisherFor(.synchronizerStopped)?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.synchronizerStopped() }
            .store(in: &cancellables)

        try synchronizer?.prepare()
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

    func synchronizerSynced() {
        stateChanged.send(.synced)
    }

    func synchronizerProgressUpdated() {
        stateChanged.send(.progressUpdated)
    }

    func synchronizerStopped() {
        stateChanged.send(.stopped)
    }

    func status() -> String {
        guard let synchronizer = synchronizer else {
            return ""
        }
        
        return SDKSynchronizer.textFor(state: synchronizer.status)
    }

    func getShieldedBalance() -> Effect<Balance, Never> {
        if let shieldedVerifiedBalance = synchronizer?.getShieldedVerifiedBalance(),
        let shieldedTotalBalance = synchronizer?.getShieldedBalance(accountIndex: 0) {
            return Effect(value: Balance(verified: shieldedVerifiedBalance, total: shieldedTotalBalance))
        }
        
        return .none
    }
    
    func getAllClearedTransactions() -> Effect<[TransactionState], Never> {
        if let clearedTransactions = try? synchronizer?.allClearedTransactions() {
            return Effect(value: clearedTransactions.map {
                TransactionState.init(confirmedTransaction: $0, sent: ($0.toAddress != nil))
            })
        }
        
        return .none
    }
    
    func getAllPendingTransactions() -> Effect<[TransactionState], Never> {
        if let pendingTransactions = try? synchronizer?.allPendingTransactions(),
        let syncedBlockHeight = synchronizer?.latestScannedHeight {
            return Effect(value: pendingTransactions.map {
                // TODO: - can we initialize it with latestBlockHeight: = nil?
                TransactionState.init(pendingTransaction: $0, latestBlockHeight: syncedBlockHeight)
            })
        }
        
        return .none
    }

    func getAllTransactions() -> Effect<[TransactionState], Never> {
        if let pendingTransactions = try? synchronizer?.allPendingTransactions(),
        let clearedTransactions = try? synchronizer?.allClearedTransactions(),
        let syncedBlockHeight = synchronizer?.latestScannedHeight {
            let clearedTxs = clearedTransactions.map {
                TransactionState.init(confirmedTransaction: $0, sent: ($0.toAddress != nil))
            }
            let pendingTxs = pendingTransactions.map {
                TransactionState.init(pendingTransaction: $0, latestBlockHeight: syncedBlockHeight)
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

    func getTransparentAddress(account: Int) -> TransparentAddress? {
        synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? {
        synchronizer?.getShieldedAddress(accountIndex: account)
    }
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        Deferred {
            Future { [weak self] promise in
                self?.synchronizer?.sendToAddress(
                    spendingKey: spendingKey,
                    zatoshi: zatoshi.amount,
                    toAddress: recipientAddress,
                    memo: memo,
                    from: account) { result in
                        switch result {
                        case .failure(let error as NSError):
                            promise(.failure(error))
                        case .success(let pendingTx):
                            promise(.success(TransactionState(pendingTransaction: pendingTx)))
                        }
                }
            }
        }
        .mapError { $0 as NSError }
        .catchToEffect()
    }
}

class MockWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private var cancellables: [AnyCancellable] = []
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var notificationCenter: WrappedNotificationCenter

    init(notificationCenter: WrappedNotificationCenter = .mock) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer) throws {
        try synchronizer?.prepare()
    }

    func start(retry: Bool) throws {
        try synchronizer?.start(retry: retry)
    }

    func stop() {
        synchronizer?.stop()
    }

    func synchronizerSynced() {
        stateChanged.send(.synced)
    }

    func status() -> String {
        guard let synchronizer = synchronizer else {
            return ""
        }
        
        return SDKSynchronizer.textFor(state: synchronizer.status)
    }

    func getShieldedBalance() -> Effect<Balance, Never> {
        return Effect(value: Balance(verified: 12345000, total: 12345000))
    }
    
    func getAllClearedTransactions() -> Effect<[TransactionState], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(amount: 1), status: .paid(success: false), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(amount: 2), uuid: "2"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(amount: 3), status: .paid(success: true), uuid: "3"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(amount: 4), uuid: "4"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(amount: 5), uuid: "5")
        ]
        
        return Effect(
            value:
                mocked.map {
                    TransactionState.placeholder(
                        date: Date.init(timeIntervalSince1970: $0.date),
                        amount: $0.amount,
                        shielded: $0.shielded,
                        status: $0.status,
                        subtitle: $0.subtitle,
                        uuid: $0.uuid
                    )
                }
        )
    }

    func getAllPendingTransactions() -> Effect<[TransactionState], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039606, amount: Zatoshi(amount: 6), status: .paid(success: false), subtitle: "pending"),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(amount: 7), subtitle: "pending"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(amount: 8), status: .paid(success: true), subtitle: "pending"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(amount: 9), subtitle: "pending")
        ]
        
        return Effect(
            value:
                mocked.map {
                    TransactionState.placeholder(
                        date: Date.init(timeIntervalSince1970: $0.date),
                        amount: $0.amount,
                        shielded: $0.shielded,
                        status: $0.status,
                        subtitle: $0.subtitle
                    )
                }
        )
    }

    func getAllTransactions() -> Effect<[TransactionState], Never> {
        return .merge(
            getAllClearedTransactions(),
            getAllPendingTransactions()
        )
        .flatMap(Publishers.Sequence.init(sequence:))
        .collect()
        .eraseToEffect()
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? { nil }
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        let transactionState = TransactionState(
            expirationHeight: 40,
            memo: "test",
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            date: Date.init(timeIntervalSince1970: 1234567),
            id: "id",
            status: .paid(success: true),
            subtitle: "sub",
            zecAmount: Zatoshi(amount: 10)
        )
        
        return Effect(value: Result.success(transactionState))
    }
}

class TestWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>
    private(set) var notificationCenter: WrappedNotificationCenter

    init(notificationCenter: WrappedNotificationCenter = .mock) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func synchronizerSynced() { }

    func status() -> String { "" }

    func getShieldedBalance() -> Effect<Balance, Never> {
        return .none
    }
    
    func getAllClearedTransactions() -> Effect<[TransactionState], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(amount: 1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(amount: 2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(amount: 3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(amount: 4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(amount: 5), uuid: "ee55")
        ]
        
        return Effect(
            value:
                mocked.map {
                    TransactionState.placeholder(
                        date: Date.init(timeIntervalSince1970: $0.date),
                        amount: $0.amount,
                        shielded: $0.shielded,
                        status: $0.status,
                        subtitle: $0.subtitle,
                        uuid: $0.uuid
                    )
                }
        )
    }

    func getAllPendingTransactions() -> Effect<[TransactionState], Never> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(
                date: 1651039606,
                amount: Zatoshi(amount: 6),
                status: .paid(success: false),
                subtitle: "pending",
                uuid: "ff66"
            ),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(amount: 7), subtitle: "pending", uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(amount: 8), status: .paid(success: true), subtitle: "pending", uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(amount: 9), subtitle: "pending", uuid: "ii99")
        ]
        
        return Effect(
            value:
                mocked.map {
                    TransactionState.placeholder(
                        date: Date.init(timeIntervalSince1970: $0.date),
                        amount: $0.amount,
                        shielded: $0.shielded,
                        status: $0.status,
                        subtitle: $0.subtitle,
                        uuid: $0.uuid
                    )
                }
        )
    }

    func getAllTransactions() -> Effect<[TransactionState], Never> {
        return .merge(
            getAllClearedTransactions(),
            getAllPendingTransactions()
        )
        .flatMap(Publishers.Sequence.init(sequence:))
        .collect()
        .eraseToEffect()
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? { nil }
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        return Effect(value: Result.failure(SynchronizerError.criticalError as NSError))
    }
}
