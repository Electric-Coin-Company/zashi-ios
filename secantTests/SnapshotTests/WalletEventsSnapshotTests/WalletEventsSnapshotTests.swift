//
//  WalletEventsSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class WalletEventsSnapshotTests: XCTestCase {
    func testWalletEventDetailSnapshot() throws {
        let transaction = TransactionState(
            memo:
                """
                Testing some long memo so I can see many lines of text \
                instead of just one. This can take some time and I'm \
                bored to write all this stuff.
                """,
            minedHeight: 1_875_256,
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(amount: 1_000_000),
            id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
            status: .paid(success: true),
            subtitle: "",
            timestamp: 1234567,
            zecAmount: Zatoshi(amount: 25_000_000)
        )
        
        let walletEvent = WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        
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
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: [walletEvent])),
                verifiedBalance: Zatoshi(amount: balance.verified)
            ),
            reducer: .default,
            environment: .demo
        )
        
        // wallet event detail
        let testEnvironment = WalletEventsFlowEnvironment(
            scheduler: DispatchQueue.test.eraseToAnyScheduler(),
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            pasteboard: .test
        )
        
        ViewStore(store).send(.walletEvents(.updateRoute(.showWalletEvent(walletEvent))))
        let walletEventsStore = WalletEventsFlowStore(
            initialState: .placeHolder,
            reducer: .default,
            environment: testEnvironment
        )
        
        addAttachments(
            name: "\(#function)_WalletEventDetail",
            TransactionDetailView(transaction: transaction, viewStore: ViewStore(walletEventsStore))
        )
    }
}
