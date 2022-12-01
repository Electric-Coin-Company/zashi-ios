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
        let transactionsHelper: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: true), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), status: .pending, uuid: "2"),
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
            
            return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        }
        
        let balance = WalletBalance(verified: 12_345_000, total: 12_345_000)

        let store = HomeStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
                walletEventsState: .init(walletEvents: IdentifiedArrayOf(uniqueElements: walletEvents))
            ),
            reducer: HomeReducer()
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
        )

        // landing home screen
        addAttachments(
            name: "\(#function)_initial",
            HomeView(store: store)
        )
        
        // all transactions
        ViewStore(store).send(.updateDrawer(.full))
        addAttachments(HomeView(store: store))
    }
    
    func testWalletEventDetailSnapshot_sent() throws {
        let transaction = TransactionState(
            memo: try? Memo(string:
                """
                Testing some long memo so I can see many lines of text \
                instead of just one. This can take some time and I'm \
                bored to write all this stuff.
                """),
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
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
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
        let transaction = TransactionState(
            memo: try? Memo(string:
                """
                Testing some long memo so I can see many lines of text \
                instead of just one. This can take some time and I'm \
                bored to write all this stuff.
                """),
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
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
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
        let transaction = TransactionState(
            memo: try? Memo(string:
                """
                Testing some long memo so I can see many lines of text \
                instead of just one. This can take some time and I'm \
                bored to write all this stuff.
                """),
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
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
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
        let transaction = TransactionState(
            errorMessage: "possible roll back",
            memo: try? Memo(string:
                """
                Testing some long memo so I can see many lines of text \
                instead of just one. This can take some time and I'm \
                bored to write all this stuff.
                """),
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
                drawerOverlay: .partial,
                profileState: .placeholder,
                requestState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                shieldedBalance: balance,
                synchronizerStatusSnapshot: .default,
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
