//
//  WalletEventsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.04.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import PasteboardClient
import Models
@testable import secant_testnet

class WalletEventsTests: XCTestCase {
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

    @MainActor func testSynchronizerStateChanged2Synced() async throws {
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
                status: $0.amount.amount > 5 ? .sending : $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return WalletEvent(
                id: transaction.id,
                state: .transaction(transaction),
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

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        await store.receive(.updateWalletEvents(walletEvents)) { state in
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
        
        await store.finish()
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
