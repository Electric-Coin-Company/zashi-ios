//
//  WalletEventsSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class WalletEventsSnapshotTests: XCTestCase {
    func testFullWalletEventsSnapshot() throws {
        let store = WalletEventsFlowStore(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
        )
        
        // landing wallet events screen
        addAttachments(
            name: "\(#function)_initial",
            WalletEventsFlowView(store: store)
        )
    }
    
    func testWalletEventDetailSnapshot_sent() throws {
        let memo = try? Memo(string:
            """
            Testing some long memo so I can see many lines of text \
            instead of just one. This can take some time and I'm \
            bored to write all this stuff.
            """)
        guard let memo else {
            XCTFail("testWalletEventDetailSnapshot_sent: memo is expected to be successfuly initialized")
            return
        }
                
        let transaction = TransactionState(
            memos: [memo],
            minedHeight: 1_875_256,
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(1_000_000),
            id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
            status: .paid(success: true),
            timestamp: 1234567,
            zecAmount: Zatoshi(25_000_000)
        )
        
        let walletEvent = WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        
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
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: [walletEvent]))
            ),
            reducer: HomeReducer()
        )
        
        ViewStore(store).send(.walletEvents(.updateDestination(.showWalletEvent(walletEvent))))
        let walletEventsStore = WalletEventsFlowStore(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
        )
        
        addAttachments(
            name: "\(#function)_WalletEventDetail",
            TransactionDetailView(transaction: transaction, store: walletEventsStore)
        )
    }
    
    func testWalletEventDetailSnapshot_received() throws {
        let memo = try? Memo(string:
            """
            Testing some long memo so I can see many lines of text \
            instead of just one. This can take some time and I'm \
            bored to write all this stuff.
            """)
        guard let memo else {
            XCTFail("testWalletEventDetailSnapshot_received: memo is expected to be successfuly initialized")
            return
        }

        let transaction = TransactionState(
            memos: [memo],
            minedHeight: 1_875_256,
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(1_000_000),
            id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
            status: .received,
            timestamp: 1234567,
            zecAmount: Zatoshi(25_000_000)
        )
        
        let walletEvent = WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        
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
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: [walletEvent]))
            ),
            reducer: HomeReducer()
        )
        
        ViewStore(store).send(.walletEvents(.updateDestination(.showWalletEvent(walletEvent))))
        let walletEventsStore = WalletEventsFlowStore(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
        )
        
        addAttachments(
            name: "\(#function)_WalletEventDetail",
            TransactionDetailView(transaction: transaction, store: walletEventsStore)
        )
    }
    
    func testWalletEventDetailSnapshot_pending() throws {
        let memo = try? Memo(string:
            """
            Testing some long memo so I can see many lines of text \
            instead of just one. This can take some time and I'm \
            bored to write all this stuff.
            """)
        guard let memo else {
            XCTFail("testWalletEventDetailSnapshot_pending: memo is expected to be successfuly initialized")
            return
        }

        let transaction = TransactionState(
            memos: [memo],
            minedHeight: 1_875_256,
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(1_000_000),
            id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
            status: .pending,
            timestamp: 1234567,
            zecAmount: Zatoshi(25_000_000)
        )
        
        let walletEvent = WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        
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
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: [walletEvent]))
            ),
            reducer: HomeReducer()
        )
        
        let walletEventsState = WalletEventsFlowReducer.State(
            requiredTransactionConfirmations: 10,
            walletEvents: .placeholder
        )
        
        ViewStore(store).send(.walletEvents(.updateDestination(.showWalletEvent(walletEvent))))
        let walletEventsStore = WalletEventsFlowStore(
            initialState: walletEventsState,
            reducer: WalletEventsFlowReducer()
        )
        
        addAttachments(
            name: "\(#function)_WalletEventDetail",
            TransactionDetailView(transaction: transaction, store: walletEventsStore)
        )
    }
    
    func testWalletEventDetailSnapshot_failed() throws {
        let memo = try? Memo(string:
            """
            Testing some long memo so I can see many lines of text \
            instead of just one. This can take some time and I'm \
            bored to write all this stuff.
            """)
        guard let memo else {
            XCTFail("testWalletEventDetailSnapshot_failed: memo is expected to be successfuly initialized")
            return
        }

        let transaction = TransactionState(
            errorMessage: "possible roll back",
            memos: [memo],
            minedHeight: 1_875_256,
            zAddress: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po",
            fee: Zatoshi(1_000_000),
            id: "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8",
            status: .failed,
            timestamp: 1234567,
            zecAmount: Zatoshi(25_000_000)
        )
        
        let walletEvent = WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        
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
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: [walletEvent]))
            ),
            reducer: HomeReducer()
        )
        
        ViewStore(store).send(.walletEvents(.updateDestination(.showWalletEvent(walletEvent))))
        let walletEventsStore = WalletEventsFlowStore(
            initialState: .placeHolder,
            reducer: WalletEventsFlowReducer()
        )
        
        addAttachments(
            name: "\(#function)_WalletEventDetail",
            TransactionDetailView(transaction: transaction, store: walletEventsStore)
        )
    }
}
