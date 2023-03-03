//
//  SDKSynchronizerTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit

extension SDKSynchronizerDependency: TestDependencyKey {
    static let testValue: SDKSynchronizerClient = NoopSDKSynchronizer()
}

class NoopSDKSynchronizer: SDKSynchronizerClient {
    private(set) var notificationCenter: NotificationCenterClient
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<SDKSynchronizerState, Never>
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: NotificationCenterClient = .noOp) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func isSyncing() -> Bool { false }

    func isInitialized() -> Bool { false }
    
    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) { }

    func statusSnapshot() -> SyncStatusSnapshot { .default }

    func rewind(_ policy: RewindPolicy) -> AnyPublisher<Void, Error>? { Empty<Void, Error>().eraseToAnyPublisher() }

    func getShieldedBalance() -> WalletBalance? { nil }
    
    func getTransparentBalance() -> WalletBalance? { nil }

    func getAllSentTransactions() -> EffectTask<[WalletEvent]> { EffectTask(value: []) }

    func getAllReceivedTransactions() -> EffectTask<[WalletEvent]> { EffectTask(value: []) }

    func getAllClearedTransactions() -> EffectTask<[WalletEvent]> { EffectTask(value: []) }

    func getAllPendingTransactions() -> EffectTask<[WalletEvent]> { EffectTask(value: []) }

    func getAllTransactions() -> EffectTask<[WalletEvent]> { EffectTask(value: []) }

    func getUnifiedAddress(account: Int) -> UnifiedAddress? { nil }
    
    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getSaplingAddress(accountIndex account: Int) -> SaplingAddress? { nil }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) -> EffectTask<Result<TransactionState, NSError>> {
        EffectTask(value: Result.failure(SynchronizerError.criticalError as NSError))
    }
    
    func updateStateChanged(_ newState: SDKSynchronizerState) {
        stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(newState)
    }
    
    func wipe() -> AnyPublisher<Void, Error>? { nil }
}

class TestSDKSynchronizerClient: SDKSynchronizerClient {
    private(set) var notificationCenter: NotificationCenterClient
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<SDKSynchronizerState, Never>
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: NotificationCenterClient = .noOp) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer, seedBytes: [UInt8]) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func isSyncing() -> Bool { false }

    func isInitialized() -> Bool { false }

    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) { }

    func statusSnapshot() -> SyncStatusSnapshot { .default }

    func rewind(_ policy: RewindPolicy) -> AnyPublisher<Void, Error>? { nil }
    
    func getShieldedBalance() -> WalletBalance? { nil }
    
    func getTransparentBalance() -> WalletBalance? { nil }

    func getAllSentTransactions() -> EffectTask<[WalletEvent]> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55")
        ]
        
        return EffectTask(
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
    
    func getAllReceivedTransactions() -> EffectTask<[WalletEvent]> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55")
        ]
        
        return EffectTask(
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
    
    func getAllClearedTransactions() -> EffectTask<[WalletEvent]> {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55")
        ]
        
        return EffectTask(
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

    func getAllPendingTransactions() -> EffectTask<[WalletEvent]> {
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
        
        return EffectTask(
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

    func getAllTransactions() -> EffectTask<[WalletEvent]> {
        return .merge(
            getAllClearedTransactions(),
            getAllPendingTransactions()
        )
        .flatMap(Publishers.Sequence.init(sequence:))
        .collect()
        .eraseToEffect()
    }

    func getUnifiedAddress(account: Int) -> UnifiedAddress? { nil }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }

    func getSaplingAddress(accountIndex account: Int) -> SaplingAddress? {
        // swiftlint:disable:next force_try
        try! SaplingAddress(encoding: "ztestsapling1edm52k336nk70gxqxedd89slrrf5xwnnp5rt6gqnk0tgw4mynv6fcx42ym6x27yac5amvfvwypz", network: .testnet)
    }
    
    func sendTransaction(
        with spendingKey: UnifiedSpendingKey,
        zatoshi: Zatoshi,
        to recipientAddress: Recipient,
        memo: Memo?
    ) -> EffectTask<Result<TransactionState, NSError>> {
        return EffectTask(value: Result.failure(SynchronizerError.criticalError as NSError))
    }
    
    func updateStateChanged(_ newState: SDKSynchronizerState) {
        stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(newState)
    }

    func wipe() -> AnyPublisher<Void, Error>? { nil }
}
