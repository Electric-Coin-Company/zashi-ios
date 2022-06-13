//
//  HomeSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class HomeSnapshotTests: XCTestCase {
    func testHomeSnapshot() throws {
        let transactionsHelper: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(amount: 1), status: .paid(success: false), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(amount: 2), uuid: "2"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(amount: 3), status: .paid(success: true), uuid: "3"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(amount: 4), uuid: "4"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(amount: 5), uuid: "5")
        ]
        let transactions = transactionsHelper.map {
            TransactionState.placeholder(
                date: Date.init(timeIntervalSince1970: $0.date),
                amount: $0.amount,
                shielded: $0.shielded,
                status: $0.status,
                subtitle: $0.subtitle,
                uuid: $0.uuid
            )
        }
        
        let balance = Balance(verified: 12_345_000, total: 12_345_000)

        let store = HomeStore(
            initialState: .init(
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                sendState: .placeholder,
                scanState: .placeholder,
                synchronizerStatus: "",
                totalBalance: Zatoshi(amount: balance.total),
                transactionHistoryState: .init(transactions: IdentifiedArrayOf(uniqueElements: transactions)),
                verifiedBalance: Zatoshi(amount: balance.verified)
            ),
            reducer: .default,
            environment: .demo
        )

        // landing home screen
        addAttachments(
            name: "\(#function)_initial",
            HomeView(store: store)
        )
        
        // all transactions
        ViewStore(store).send(.updateDrawer(.full))
        addAttachments(
            name: "\(#function)_fullTransactionHistory",
            HomeView(store: store)
        )
    }
}
