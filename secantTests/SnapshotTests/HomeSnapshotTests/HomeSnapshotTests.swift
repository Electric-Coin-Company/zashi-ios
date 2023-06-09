//
//  HomeSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Models
import Home
@testable import secant_testnet

class HomeSnapshotTests: XCTestCase {
    func testHomeSnapshot() throws {
        let transactionsHelper: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: true), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), status: .sending, uuid: "2"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .received, uuid: "3"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), status: .failed, uuid: "4")
        ]
        
        let walletEvents: [WalletEvent] = transactionsHelper.map {
            var transaction = TransactionState.placeholder(
                amount: $0.amount,
                fee: Zatoshi(10),
                shielded: $0.shielded,
                status: $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            transaction.zAddress = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
            
            return WalletEvent(id: transaction.id, state: .transaction(transaction), timestamp: transaction.timestamp)
        }
        
        let balance = WalletBalance(verified: 12_345_000, total: 12_345_000)

        let store = HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                profileState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                settingsState: .placeholder,
                shieldedBalance: balance.redacted,
                synchronizerStatusSnapshot: .default,
                walletConfig: .default,
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: walletEvents))
            ),
            reducer: HomeReducer(networkType: .testnet)
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
                .dependency(\.reviewRequest, .noOp)
        )

        // landing home screen
        addAttachments(HomeView(store: store, tokenName: "ZEC"))
    }
}
