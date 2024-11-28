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

@DependencyClient
public struct SDKSynchronizerClient {
    public enum CreateProposedTransactionsResult: Equatable {
        case failure(txIds: [String], code: Int, description: String)
        case grpcFailure(txIds: [String])
        case partial(txIds: [String], statuses: [String])
        case success(txIds: [String])
    }
    
    public let stateStream: () -> AnyPublisher<SynchronizerState, Never>
    public let eventStream: () -> AnyPublisher<SynchronizerEvent, Never>
    public let exchangeRateUSDStream: () -> AnyPublisher<FiatCurrencyResult?, Never>
    public let latestState: () -> SynchronizerState
    
    public let prepareWith: ([UInt8], BlockHeight, WalletInitMode) async throws -> Void
    public let start: (_ retry: Bool) async throws -> Void
    public let stop: () -> Void
    public let isSyncing: () -> Bool
    public let isInitialized: () -> Bool
    
    public let rewind: (RewindPolicy) -> AnyPublisher<Void, Error>
    
    public var getAllTransactions: () async throws -> [TransactionState]
    public var getMemos: (Data) async throws -> [Memo]

    public let getUnifiedAddress: (_ account: Zip32AccountIndex) async throws -> UnifiedAddress?
    public let getTransparentAddress: (_ account: Zip32AccountIndex) async throws -> TransparentAddress?
    public let getSaplingAddress: (_ account: Zip32AccountIndex) async throws -> SaplingAddress?
    
    public let getAccountBalance: (_ account: Zip32AccountIndex) async throws -> AccountBalance?
    
    public var sendTransaction: (UnifiedSpendingKey, Zatoshi, Recipient, Memo?) async throws -> TransactionState
    public let shieldFunds: (UnifiedSpendingKey, Memo, Zatoshi) async throws -> TransactionState
    
    public var wipe: () -> AnyPublisher<Void, Error>?
    
    public var switchToEndpoint: (LightWalletEndpoint) async throws -> Void
    
    // Proposals
    public var proposeTransfer: (Zip32AccountIndex, Recipient, Zatoshi, Memo?) async throws -> Proposal
    public var createProposedTransactions: (Proposal, UnifiedSpendingKey) async throws -> CreateProposedTransactionsResult
    public var proposeShielding: (Zip32AccountIndex, Zatoshi, Memo, TransparentAddress?) async throws -> Proposal?

    public var isSeedRelevantToAnyDerivedAccount: ([UInt8]) async throws -> Bool
    
    public var refreshExchangeRateUSD: () -> Void

    public var evaluateBestOf: ([LightWalletEndpoint], Double, Double, UInt64, Int, NetworkType) async -> [LightWalletEndpoint] = { _,_,_,_,_,_ in [] }
    
    public var walletAccounts: () -> [WalletAccount] = { [] }
}
