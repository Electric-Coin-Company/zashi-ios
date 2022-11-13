//
//  SDKSynchronizerTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import Combine
import ComposableArchitecture
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

    func prepareWith(initializer: Initializer) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func synchronizerSynced(_ synchronizerState: SDKSynchronizer.SynchronizerState?) { }

    func statusSnapshot() -> SyncStatusSnapshot { .default }

    func rewind(_ policy: RewindPolicy) throws { }
    
    func getShieldedBalance() -> WalletBalance? { nil }
    
    func getTransparentBalance() -> WalletBalance? { nil }

    func getAllClearedTransactions() -> Effect<[WalletEvent], Never> { Effect(value: []) }

    func getAllPendingTransactions() -> Effect<[WalletEvent], Never> { Effect(value: []) }

    func getAllTransactions() -> Effect<[WalletEvent], Never> { Effect(value: []) }

    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? { nil }
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        Effect(value: Result.failure(SynchronizerError.criticalError as NSError))
    }
    
    func updateStateChanged(_ newState: SDKSynchronizerState) {
        stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(newState)
    }
}

class T2estSDKSynchronizerClient: SDKSynchronizerClient {
    private(set) var blockProcessor: CompactBlockProcessor?
    private(set) var notificationCenter: NotificationCenterClient
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<SDKSynchronizerState, Never>
    private(set) var walletBirthday: BlockHeight?
    private(set) var latestScannedSynchronizerState: SDKSynchronizer.SynchronizerState?

    init(notificationCenter: NotificationCenterClient = .noOp) {
        self.notificationCenter = notificationCenter
        self.stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer) throws { }

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
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? { "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8" }
    
    func sendTransaction(
        with spendingKey: String,
        zatoshi: Zatoshi,
        to recipientAddress: String,
        memo: String?,
        from account: Int
    ) -> Effect<Result<TransactionState, NSError>, Never> {
        return Effect(value: Result.failure(SynchronizerError.criticalError as NSError))
    }
    
    func updateStateChanged(_ newState: SDKSynchronizerState) {
        stateChanged = CurrentValueSubject<SDKSynchronizerState, Never>(newState)
    }
}
