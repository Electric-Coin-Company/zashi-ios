//
//  TransactionListSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.06.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Models
import TransactionList
import Home
@testable import secant_testnet

class TransactionListSnapshotTests: XCTestCase {
    func testFullTransactionListSnapshot() throws {
        let store = TransactionListStore(
            initialState: .placeHolder,
            reducer: TransactionListReducer()
                .dependency(\.sdkSynchronizer, .mock)
                .dependency(\.mainQueue, .immediate)
        )
        
        // landing wallet events screen
        addAttachments(
            name: "\(#function)_initial",
            TransactionListView(store: store, tokenName: "ZEC")
        )
    }
}
