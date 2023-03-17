//
//  WalletEventsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.04.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class WalletEventsTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    func testSynchronizerSubscription() throws {
        let store = TestStore(
            initialState: WalletEventsFlowReducer.State(
                destination: .latest,
                isScrollable: true,
                walletEvents: []
            ),
            reducer: WalletEventsFlowReducer()
        )

        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.mainQueue = .immediate

        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        store.receive(.synchronizerStateChanged(.unprepared))

        // ending the subscription
        store.send(.onDisappear)
    }

    func testSynchronizerStateChanged2Synced() throws {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55"),
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

        let walletEvents: [WalletEvent] = mocked.map {
            let transaction = TransactionState.placeholder(
                amount: $0.amount,
                fee: Zatoshi(10),
                shielded: $0.shielded,
                status: $0.amount.amount > 5 ? .pending : $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return WalletEvent(
                id: transaction.id,
                state: transaction.status == .pending ? .pending(transaction) : .send(transaction),
                timestamp: transaction.timestamp
            )
        }

        let identifiedWalletEvents = IdentifiedArrayOf(uniqueElements: walletEvents)

        let store = TestStore(
            initialState: WalletEventsFlowReducer.State(
                destination: .latest,
                isScrollable: true,
                walletEvents: identifiedWalletEvents
            ),
            reducer: WalletEventsFlowReducer()
        )

        store.dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()
        store.dependencies.sdkSynchronizer = .mocked()

        store.send(.synchronizerStateChanged(.synced)) { state in
            state.latestMinedHeight = 0
        }

        Self.testScheduler.advance(by: 0.01)

        store.receive(.updateWalletEvents(walletEvents)) { state in
            let receivedWalletEvents = IdentifiedArrayOf(
                uniqueElements:
                    walletEvents
                    .sorted(by: { lhs, rhs in
                        guard let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp else {
                            return false
                        }
                        return lhsTimestamp > rhsTimestamp
                    })
            )

            state.walletEvents = receivedWalletEvents
        }
    }

    func testCopyToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard

        let store = TestStore(
            initialState: WalletEventsFlowReducer.State(
                destination: .latest,
                isScrollable: true,
                walletEvents: []
            ),
            reducer: WalletEventsFlowReducer()
        )
            
        store.dependencies.pasteboard = testPasteboard

        let testText = "test text".redacted
        store.send(.copyToPastboard(testText))

        XCTAssertEqual(
            testPasteboard.getString()?.data,
            testText.data,
            "WalletEvetns: `testCopyToPasteboard` is expected to match the input `\(testText.data)`"
        )
    }
}
