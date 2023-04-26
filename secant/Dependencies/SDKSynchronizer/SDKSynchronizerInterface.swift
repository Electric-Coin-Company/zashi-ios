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
        get { self[SDKSynchronizerClient.self] }
        set { self[SDKSynchronizerClient.self] = newValue }
    }
}

struct SDKSynchronizerClient {
    let stateStream: () -> AnyPublisher<SynchronizerState, Never>
    let eventStream: () -> AnyPublisher<SynchronizerEvent, Never>
    let latestState: () -> SynchronizerState
    let latestScannedHeight: () -> BlockHeight

    let prepareWith: ([UInt8], UnifiedFullViewingKey, BlockHeight) async throws -> Void
    let start: (_ retry: Bool) async throws -> Void
    let stop: () async -> Void
    let isSyncing: () -> Bool
    let isInitialized: () -> Bool

    let rewind: (RewindPolicy) -> AnyPublisher<Void, Error>

    let getShieldedBalance: () -> WalletBalance?
    let getTransparentBalance: () -> WalletBalance?
    let getAllTransactions: () async throws -> [WalletEvent]

    let getUnifiedAddress: (_ account: Int) async throws -> UnifiedAddress?
    let getTransparentAddress: (_ account: Int) async throws -> TransparentAddress?
    let getSaplingAddress: (_ accountIndex: Int) async throws -> SaplingAddress?

    let sendTransaction: (UnifiedSpendingKey, Zatoshi, Recipient, Memo?) -> EffectTask<Result<TransactionState, NSError>>

    let shieldFunds: (UnifiedSpendingKey, Memo, Zatoshi) async throws -> TransactionState

    let wipe: () -> AnyPublisher<Void, Error>?
}
