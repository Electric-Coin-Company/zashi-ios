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
    
    func prepareWith(initializer: Initializer) throws
    func start(retry: Bool) throws
    func stop()
    func synchronizerSynced()

    func getShieldedBalance() -> Effect<Balance, Never>

    func getTransparentAddress(account: Int) -> TransparentAddress?
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress?
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

    init() {
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }
    
    deinit {
        synchronizer?.stop()
    }

    func prepareWith(initializer: Initializer) throws {
        synchronizer = try SDKSynchronizer(initializer: initializer)

        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.synchronizerSynced()
            })
            .store(in: &cancellables)
        
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

    func getShieldedBalance() -> Effect<Balance, Never> {
        if let shieldedVerifiedBalance = synchronizer?.getShieldedVerifiedBalance(),
        let shieldedTotalBalance = synchronizer?.getShieldedBalance(accountIndex: 0) {
            return Effect(value: Balance(verified: shieldedVerifiedBalance, total: shieldedTotalBalance))
        }
        
        return .none
    }
    
    func getTransparentAddress(account: Int) -> TransparentAddress? {
        synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? {
        synchronizer?.getShieldedAddress(accountIndex: account)
    }
}

class MockWrappedSDKSynchronizer: WrappedSDKSynchronizer {
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var stateChanged: CurrentValueSubject<WrappedSDKSynchronizerState, Never>

    init() {
        self.stateChanged = CurrentValueSubject<WrappedSDKSynchronizerState, Never>(.unknown)
    }

    func prepareWith(initializer: Initializer) throws { }

    func start(retry: Bool) throws { }

    func stop() { }

    func synchronizerSynced() { }

    func getShieldedBalance() -> Effect<Balance, Never> {
        return .none
    }
    
    func getTransparentAddress(account: Int) -> TransparentAddress? { nil }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? { nil }
}
