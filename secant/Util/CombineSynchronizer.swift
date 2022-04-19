//
//  CombineSynchronizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.04.2022.
//

import Foundation
import ZcashLightClientKit
import Combine

struct Balance: WalletBalance, Equatable {
    var verified: Int64
    var total: Int64
}

protocol CombineSynchronizer {
    var synchronizer: SDKSynchronizer? { get }
    var shieldedBalance: CurrentValueSubject<WalletBalance, Never> { get }
    
    func prepareWith(initializer: Initializer) throws
    func start(retry: Bool) throws
    func stop()
    func updatePublishers()

    func getTransparentAddress(account: Int) -> TransparentAddress?
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress?
}

extension CombineSynchronizer {
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

class LiveCombineSynchronizer: CombineSynchronizer {
    private var cancellables: [AnyCancellable] = []
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var shieldedBalance: CurrentValueSubject<WalletBalance, Never>

    init() {
        self.shieldedBalance = CurrentValueSubject<WalletBalance, Never>(Balance(verified: 0, total: 0))
    }

    func prepareWith(initializer: Initializer) throws {
        synchronizer = try SDKSynchronizer(initializer: initializer)

        NotificationCenter.default.publisher(for: .synchronizerSynced)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updatePublishers()
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

    func updatePublishers() {
        if let shieldedVerifiedBalance = synchronizer?.getShieldedVerifiedBalance(),
        let shieldedTotalBalance = synchronizer?.getShieldedBalance(accountIndex: 0) {
            shieldedBalance.send(Balance(verified: shieldedVerifiedBalance, total: shieldedTotalBalance))
        } else {
            shieldedBalance.send(Balance(verified: 0, total: 0))
        }
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? {
        synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? {
        synchronizer?.getShieldedAddress(accountIndex: account)
    }
}

class MockCombineSynchronizer: CombineSynchronizer {
    private(set) var synchronizer: SDKSynchronizer?
    private(set) var shieldedBalance: CurrentValueSubject<WalletBalance, Never>

    init() {
        self.shieldedBalance = CurrentValueSubject<WalletBalance, Never>(Balance(verified: 0, total: 0))
    }

    func prepareWith(initializer: Initializer) throws {
        synchronizer = try SDKSynchronizer(initializer: initializer)
        shieldedBalance = CurrentValueSubject<WalletBalance, Never>(
            Balance(verified: 0, total: 0)
        )
        try synchronizer?.prepare()
    }

    func start(retry: Bool) throws {
        try synchronizer?.start(retry: retry)
    }

    func stop() {
        synchronizer?.stop()
    }

    func updatePublishers() {
    }

    func getTransparentAddress(account: Int) -> TransparentAddress? {
        synchronizer?.getTransparentAddress(accountIndex: account)
    }
    
    func getShieldedAddress(account: Int) -> SaplingShieldedAddress? {
        synchronizer?.getShieldedAddress(accountIndex: account)
    }
}
