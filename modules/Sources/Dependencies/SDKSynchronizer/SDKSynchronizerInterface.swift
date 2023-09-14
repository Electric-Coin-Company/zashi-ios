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
import Models

extension DependencyValues {
    public var sdkSynchronizer: SDKSynchronizerClient {
        get { self[SDKSynchronizerClient.self] }
        set { self[SDKSynchronizerClient.self] = newValue }
    }
}

public struct SDKSynchronizerClient {
    public let stateStream: () -> AnyPublisher<SynchronizerState, Never>
    public let eventStream: () -> AnyPublisher<SynchronizerEvent, Never>
    public let latestState: () -> SynchronizerState

    public let prepareWith: ([UInt8], BlockHeight, WalletInitMode) async throws -> Void
    public let start: (_ retry: Bool) async throws -> Void
    public let stop: () -> Void
    public let isSyncing: () -> Bool
    public let isInitialized: () -> Bool

    public let rewind: (RewindPolicy) -> AnyPublisher<Void, Error>

    public let getShieldedBalance: () -> WalletBalance?
    public let getTransparentBalance: () -> WalletBalance?
    public let getAllTransactions: () async throws -> [WalletEvent]

    public let getUnifiedAddress: (_ account: Int) async throws -> UnifiedAddress?
    public let getTransparentAddress: (_ account: Int) async throws -> TransparentAddress?
    public let getSaplingAddress: (_ accountIndex: Int) async throws -> SaplingAddress?

    public var sendTransaction: (UnifiedSpendingKey, Zatoshi, Recipient, Memo?) async throws -> TransactionState
    public let shieldFunds: (UnifiedSpendingKey, Memo, Zatoshi) async throws -> TransactionState

    public let wipe: () -> AnyPublisher<Void, Error>?
}
