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
    public enum CreateProposedTransactionsResult: Equatable {
        case failure
        case partial(txIds: [String], statuses: [String])
        case success
    }
    
    public let stateStream: () -> AnyPublisher<SynchronizerState, Never>
    public let eventStream: () -> AnyPublisher<SynchronizerEvent, Never>
    public let latestState: () -> SynchronizerState

    public let prepareWith: ([UInt8], BlockHeight, WalletInitMode) async throws -> Void
    public let start: (_ retry: Bool) async throws -> Void
    public let stop: () -> Void
    public let isSyncing: () -> Bool
    public let isInitialized: () -> Bool

    public let rewind: (RewindPolicy) -> AnyPublisher<Void, Error>

    public var getAllTransactions: () async throws -> [TransactionState]

    public let getUnifiedAddress: (_ account: Int) async throws -> UnifiedAddress?
    public let getTransparentAddress: (_ account: Int) async throws -> TransparentAddress?
    public let getSaplingAddress: (_ accountIndex: Int) async throws -> SaplingAddress?

    public var sendTransaction: (UnifiedSpendingKey, Zatoshi, Recipient, Memo?) async throws -> TransactionState
    public let shieldFunds: (UnifiedSpendingKey, Memo, Zatoshi) async throws -> TransactionState

    public var wipe: () -> AnyPublisher<Void, Error>?
    
    public var switchToEndpoint: (LightWalletEndpoint) async throws -> Void
    
    // Proposals
    public var proposeTransfer: (Int, Recipient, Zatoshi, Memo?) async throws -> Proposal
    public var createProposedTransactions: (Proposal, UnifiedSpendingKey) async throws -> CreateProposedTransactionsResult
    public var proposeShielding: (Int, Zatoshi, Memo, TransparentAddress?) async throws -> Proposal?
}
