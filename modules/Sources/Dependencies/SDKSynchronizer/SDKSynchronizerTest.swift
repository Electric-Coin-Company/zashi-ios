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
import Models
import Utils

extension SDKSynchronizerClient: TestDependencyKey {
    public static let testValue = Self(
        stateStream: unimplemented("\(Self.self).stateStream", placeholder: Empty().eraseToAnyPublisher()),
        eventStream: unimplemented("\(Self.self).eventStream", placeholder: Empty().eraseToAnyPublisher()),
        exchangeRateUSDStream: unimplemented("\(Self.self).exchangeRateUSDStream", placeholder: Empty().eraseToAnyPublisher()),
        latestState: unimplemented("\(Self.self).latestState", placeholder: .zero),
        prepareWith: unimplemented("\(Self.self).prepareWith"),
        start: unimplemented("\(Self.self).start"),
        stop: unimplemented("\(Self.self).stop", placeholder: {}()),
        isSyncing: unimplemented("\(Self.self).isSyncing", placeholder: false),
        isInitialized: unimplemented("\(Self.self).isInitialized", placeholder: false),
        rewind: unimplemented("\(Self.self).rewind", placeholder: Fail(error: "Error").eraseToAnyPublisher()),
        getAllTransactions: unimplemented("\(Self.self).getAllTransactions", placeholder: []),
        getMemos: unimplemented("\(Self.self).getMemos", placeholder: []),
        getUnifiedAddress: unimplemented("\(Self.self).getUnifiedAddress", placeholder: nil),
        getTransparentAddress: unimplemented("\(Self.self).getTransparentAddress", placeholder: nil),
        getSaplingAddress: unimplemented("\(Self.self).getSaplingAddress", placeholder: nil),
        getAccountBalance: unimplemented("\(Self.self).getAccountBalance", placeholder: nil),
        sendTransaction: unimplemented("\(Self.self).sendTransaction", placeholder: .placeholder()),
        shieldFunds: unimplemented("\(Self.self).shieldFunds", placeholder: .placeholder()),
        wipe: unimplemented("\(Self.self).wipe", placeholder: nil),
        switchToEndpoint: unimplemented("\(Self.self).switchToEndpoint"),
        proposeTransfer: unimplemented("\(Self.self).proposeTransfer", placeholder: .testOnlyFakeProposal(totalFee: 0)),
        createProposedTransactions: unimplemented("\(Self.self).createProposedTransactions", placeholder: .success(txIds: [])),
        proposeShielding: unimplemented("\(Self.self).proposeShielding", placeholder: nil),
        isSeedRelevantToAnyDerivedAccount: unimplemented("\(Self.self).isSeedRelevantToAnyDerivedAccount"),
        refreshExchangeRateUSD: unimplemented("\(Self.self).refreshExchangeRateUSD", placeholder: {}()),
        evaluateBestOf: { _, _, _, _, _, _ in fatalError("evaluateBestOf not implemented") }
    )
}

extension SDKSynchronizerClient {
    public static let noOp = Self(
        stateStream: { Empty().eraseToAnyPublisher() },
        eventStream: { Empty().eraseToAnyPublisher() },
        exchangeRateUSDStream: { Empty().eraseToAnyPublisher() },
        latestState: { .zero },
        prepareWith: { _, _, _ in },
        start: { _ in },
        stop: { },
        isSyncing: { false },
        isInitialized: { false },
        rewind: { _ in Empty<Void, Error>().eraseToAnyPublisher() },
        getAllTransactions: { [] },
        getMemos: { _ in [] },
        getUnifiedAddress: { _ in nil },
        getTransparentAddress: { _ in nil },
        getSaplingAddress: { _ in nil },
        getAccountBalance: { _ in nil },
        sendTransaction: { _, _, _, _ in .placeholder() },
        shieldFunds: { _, _, _ in .placeholder() },
        wipe: { Empty<Void, Error>().eraseToAnyPublisher() },
        switchToEndpoint: { _ in },
        proposeTransfer: { _, _, _, _ in .testOnlyFakeProposal(totalFee: 0) },
        createProposedTransactions: { _, _ in .success(txIds: []) },
        proposeShielding: { _, _, _, _ in nil },
        isSeedRelevantToAnyDerivedAccount: { _ in false },
        refreshExchangeRateUSD: { },
        evaluateBestOf: { _, _, _, _, _, _ in [] }
    )

    public static let mock = Self.mocked()
}

extension SDKSynchronizerClient {
    public static func mocked(
        stateStream: @escaping () -> AnyPublisher<SynchronizerState, Never> = { Just(.zero).eraseToAnyPublisher() },
        eventStream: @escaping () -> AnyPublisher<SynchronizerEvent, Never> = { Empty().eraseToAnyPublisher() },
        exchangeRateUSDStream: @escaping () -> AnyPublisher<FiatCurrencyResult?, Never> = { Empty().eraseToAnyPublisher() },
        latestState: @escaping () -> SynchronizerState = { .zero },
        latestScannedHeight: @escaping () -> BlockHeight = { 0 },
        prepareWith: @escaping ([UInt8], BlockHeight, WalletInitMode) throws -> Void = { _, _, _ in },
        start: @escaping (_ retry: Bool) throws -> Void = { _ in },
        stop: @escaping () -> Void = { },
        isSyncing: @escaping () -> Bool = { false },
        isInitialized: @escaping () -> Bool = { false },
        rewind: @escaping (RewindPolicy) -> AnyPublisher<Void, Error> = { _ in return Empty<Void, Error>().eraseToAnyPublisher() },
        getAllTransactions: @escaping () -> [TransactionState] = {
            let mockedCleared: [TransactionStateMockHelper] = [
                TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid, uuid: "aa11"),
                TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
                TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid, uuid: "cc33"),
                TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
                TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55")
            ]

            var clearedTransactions = mockedCleared
                .map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.status,
                        timestamp: $0.date,
                        uuid: $0.uuid
                    )
                    return transaction
                }
        
            let mockedPending: [TransactionStateMockHelper] = [
                TransactionStateMockHelper(
                    date: 1651039606,
                    amount: Zatoshi(6),
                    status: .paid,
                    uuid: "ff66"
                ),
                TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(7), uuid: "gg77"),
                TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(8), status: .paid, uuid: "hh88"),
                TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(9), uuid: "ii99")
            ]

            let pendingTransactions = mockedPending
                .map {
                    let transaction = TransactionState.placeholder(
                        amount: $0.amount,
                        fee: Zatoshi(10),
                        shielded: $0.shielded,
                        status: $0.amount.amount > 5 ? .sending : $0.status,
                        timestamp: $0.date,
                        uuid: $0.uuid
                    )
                    return transaction
                }
            
            clearedTransactions.append(contentsOf: pendingTransactions)

            return clearedTransactions
        },
        getMemos: @escaping (_ rawID: Data) -> [Memo] = { _ in [] },
        getUnifiedAddress: @escaping (_ account: Int) -> UnifiedAddress? = { _ in
            // swiftlint:disable force_try
            try! UnifiedAddress(
                encoding: """
                utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7d\
                wyzwtgnuc76h
                """,
                network: .testnet
            )
        },
        getTransparentAddress: @escaping (_ account: Int) -> TransparentAddress? = { _ in return nil },
        getSaplingAddress: @escaping (_ accountIndex: Int) async -> SaplingAddress? = { _ in
            // swiftlint:disable:next force_try
            try! SaplingAddress(
                encoding: "ztestsapling1edm52k336nk70gxqxedd89slrrf5xwnnp5rt6gqnk0tgw4mynv6fcx42ym6x27yac5amvfvwypz",
                network: .testnet
            )
        },
        getAccountBalance: @escaping (_ accountIndex: Int) async -> AccountBalance? = { _ in nil },
        sendTransaction:
        @escaping (UnifiedSpendingKey, Zatoshi, Recipient, Memo?) async throws -> TransactionState = { _, _, _, memo in
            var memos: [Memo]? = []
            if let memo { memos?.append(memo) }

            return TransactionState(
                expiryHeight: 40,
                memos: memos,
                minedHeight: 50,
                shielded: true,
                zAddress: "tteafadlamnelkqe",
                fee: Zatoshi(10),
                id: "id",
                status: .paid,
                timestamp: 1234567,
                zecAmount: Zatoshi(10)
            )
        },
        shieldFunds: @escaping (UnifiedSpendingKey, Memo, Zatoshi) async throws -> TransactionState = { _, memo, _  in
            TransactionState(
                expiryHeight: 40,
                memos: [memo],
                minedHeight: 50,
                shielded: true,
                zAddress: "tteafadlamnelkqe",
                fee: Zatoshi(10),
                id: "id",
                status: .paid,
                timestamp: 1234567,
                zecAmount: Zatoshi(10)
            )
        },
        wipe: @escaping () -> AnyPublisher<Void, Error>? = { Fail(error: "Error").eraseToAnyPublisher() },
        switchToEndpoint: @escaping (LightWalletEndpoint) async throws -> Void = { _ in },
        proposeTransfer:
        @escaping (Int, Recipient, Zatoshi, Memo?) async throws -> Proposal = { _, _, _, _ in .testOnlyFakeProposal(totalFee: 0) },
        createProposedTransactions:
        @escaping (Proposal, UnifiedSpendingKey) async throws -> CreateProposedTransactionsResult = { _, _ in .success(txIds: []) },
        proposeShielding:
        @escaping (Int, Zatoshi, Memo, TransparentAddress?) async throws -> Proposal? = { _, _, _, _ in nil },
        isSeedRelevantToAnyDerivedAccount: @escaping ([UInt8]) async throws -> Bool = { _ in false },
        refreshExchangeRateUSD: @escaping () -> Void = { },
        evaluateBestOf: @escaping ([LightWalletEndpoint], Double, Double, UInt64, Int, NetworkType) async -> [LightWalletEndpoint] = { _, _, _, _, _, _ in [] }
    ) -> SDKSynchronizerClient {
        SDKSynchronizerClient(
            stateStream: stateStream,
            eventStream: eventStream,
            exchangeRateUSDStream: exchangeRateUSDStream,
            latestState: latestState,
            prepareWith: prepareWith,
            start: start,
            stop: stop,
            isSyncing: isSyncing,
            isInitialized: isInitialized,
            rewind: rewind,
            getAllTransactions: getAllTransactions,
            getMemos: getMemos,
            getUnifiedAddress: getUnifiedAddress,
            getTransparentAddress: getTransparentAddress,
            getSaplingAddress: getSaplingAddress,
            getAccountBalance: getAccountBalance,
            sendTransaction: sendTransaction,
            shieldFunds: shieldFunds,
            wipe: wipe,
            switchToEndpoint: switchToEndpoint,
            proposeTransfer: proposeTransfer,
            createProposedTransactions: createProposedTransactions,
            proposeShielding: proposeShielding,
            isSeedRelevantToAnyDerivedAccount: isSeedRelevantToAnyDerivedAccount,
            refreshExchangeRateUSD: refreshExchangeRateUSD,
            evaluateBestOf: evaluateBestOf
        )
    }
}
