//
//  WalletEventsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.04.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class WalletEventsTests: XCTestCase {
    static let testScheduler = DispatchQueue.test
    
    let testEnvironment = WalletEventsFlowEnvironment(
        scheduler: testScheduler.eraseToAnyScheduler(),
        SDKSynchronizer: TestWrappedSDKSynchronizer()
    )
    
    func testSynchronizerSubscription() throws {
        let store = TestStore(
            initialState: WalletEventsFlowState(
                route: .latest,
                isScrollable: true,
                walletEvents: []
            ),
            reducer: WalletEventsFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.onAppear)

        store.receive(.synchronizerStateChanged(.unknown))

        // ending the subscription
        store.send(.onDisappear)
    }

    func testSynchronizerStateChanged2Synced() throws {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(amount: 1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(amount: 2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(amount: 3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(amount: 4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(amount: 5), uuid: "ee55"),
            TransactionStateMockHelper(
                date: 1651039606,
                amount: Zatoshi(amount: 6),
                status: .paid(success: false),
                subtitle: "pending",
                uuid: "ff66"
            ),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(amount: 7), subtitle: "pending", uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(amount: 8), status: .paid(success: true), subtitle: "pending", uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(amount: 9), subtitle: "pending", uuid: "ii99")
        ]

        let walletEvents: [WalletEvent] = mocked.map {
            let transaction = TransactionState.placeholder(
                amount: $0.amount,
                shielded: $0.shielded,
                status: $0.status,
                subtitle: $0.subtitle,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return WalletEvent(
                id: transaction.id,
                state: transaction.subtitle == "pending" ? .pending(transaction) : .send(transaction),
                timestamp: transaction.timestamp
            )
        }

        let identifiedTransactions = IdentifiedArrayOf(uniqueElements: walletEvents)
        
        let store = TestStore(
            initialState: WalletEventsFlowState(
                route: .latest,
                isScrollable: true,
                walletEvents: identifiedTransactions
            ),
            reducer: WalletEventsFlowReducer.default,
            environment: testEnvironment
        )
        
        store.send(.synchronizerStateChanged(.synced))
        
        Self.testScheduler.advance(by: 0.01)

        store.receive(.updateWalletEvents(walletEvents)) { state in
            let receivedTransactions = IdentifiedArrayOf(
                uniqueElements:
                    walletEvents
                    .sorted(by: { lhs, rhs in
                        lhs.timestamp > rhs.timestamp
                    })
            )
            
            state.walletEvents = receivedTransactions
        }
    }
}
