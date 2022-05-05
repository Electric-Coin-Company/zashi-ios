//
//  TransactionHistoryTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.04.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class TransactionHistoryTests: XCTestCase {
    static let testScheduler = DispatchQueue.test
    
    let testEnvironment = TransactionHistoryEnvironment(
        scheduler: testScheduler.eraseToAnyScheduler(),
        wrappedSDKSynchronizer: TestWrappedSDKSynchronizer()
    )
    
    func testSynchronizerSubscription() throws {
        let store = TestStore(
            initialState: TransactionHistoryState(
                route: .latest,
                isScrollable: true,
                transactions: []
            ),
            reducer: TransactionHistoryReducer.default,
            environment: testEnvironment
        )
        
        store.send(.onAppear)

        store.receive(.synchronizerStateChanged(.unknown))

        // ending the subscription
        store.send(.onDisappear)
    }

    func testSynchronizerStateChanged2Synced() throws {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: 1, status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: 2, uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: 3, status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: 4, uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: 5, uuid: "ee55"),
            TransactionStateMockHelper(date: 1651039606, amount: 6, status: .paid(success: false), subtitle: "pending", uuid: "ff66"),
            TransactionStateMockHelper(date: 1651039303, amount: 7, subtitle: "pending", uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: 8, status: .paid(success: true), subtitle: "pending", uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: 9, subtitle: "pending", uuid: "ii99")
        ]

        let transactions = mocked.map {
            TransactionState.placeholder(
                date: Date.init(timeIntervalSince1970: $0.date),
                amount: $0.amount,
                shielded: $0.shielded,
                status: $0.status,
                subtitle: $0.subtitle,
                uuid: $0.uuid
            )
        }

        let identifiedTransactions = IdentifiedArrayOf(uniqueElements: transactions)
        
        let store = TestStore(
            initialState: TransactionHistoryState(
                route: .latest,
                isScrollable: true,
                transactions: identifiedTransactions
            ),
            reducer: TransactionHistoryReducer.default,
            environment: testEnvironment
        )
        
        store.send(.synchronizerStateChanged(.synced))
        
        Self.testScheduler.advance(by: 0.01)

        store.receive(.updateTransactions(transactions)) { state in
            let receivedTransactions = IdentifiedArrayOf(
                uniqueElements:
                    transactions
                    .sorted(by: { lhs, rhs in
                        lhs.date > rhs.date
                    })
            )
            
            state.transactions = receivedTransactions
        }
    }
}
