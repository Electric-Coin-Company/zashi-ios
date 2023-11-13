//
//  TransactionListTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 27.04.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import Models
import TransactionList
@testable import secant_testnet

class TransactionListTests: XCTestCase {
    @MainActor func testSynchronizerSubscription() async throws {
        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: []
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.sdkSynchronizer.getAllTransactions = { [] }
        store.dependencies.mainQueue = .immediate

        await store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        await store.receive(.synchronizerStateChanged(.unprepared))

        await store.receive(.updateTransactionList([]))

        // ending the subscription
        await store.send(.onDisappear)

        await store.finish()
    }

    @MainActor func testSynchronizerStateChanged2Synced() async throws {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid, uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid, uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55"),
            TransactionStateMockHelper(
                date: 1651039606,
                amount: Zatoshi(6),
                status: .paid,
                uuid: "ff66"
            ),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(7), uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(8), status: .paid, uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(9), uuid: "ii99")
        ]

        let transactionList: [TransactionState] = mocked.map {
            let transaction = TransactionState.placeholder(
                amount: $0.amount,
                fee: Zatoshi(10),
                shielded: $0.shielded,
                status: $0.amount.amount > 5 ? .sending : $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return transaction
        }

        let identifiedTransactionList = IdentifiedArrayOf(uniqueElements: transactionList)

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: identifiedTransactionList
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.readTransactionsStorage = .noOp

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        await store.receive(.updateTransactionList(transactionList)) { state in
            let receivedTransactionList = IdentifiedArrayOf(
                uniqueElements:
                    transactionList
                    .sorted(by: { lhs, rhs in
                        guard let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp else {
                            return false
                        }
                        return lhsTimestamp > rhsTimestamp
                    })
            )

            state.transactionList = receivedTransactionList
            state.latestTransactionList = transactionList
            state.latestTranassctionId = "ii99"
        }
        
        await store.finish()
    }
    
    @MainActor func testSynchronizerStateChanged2Synced_skippedTransactionListUpdate() async throws {
        let mocked: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid, uuid: "aa11"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "bb22"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid, uuid: "cc33"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "dd44"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "ee55"),
            TransactionStateMockHelper(
                date: 1651039606,
                amount: Zatoshi(6),
                status: .paid,
                uuid: "ff66"
            ),
            TransactionStateMockHelper(date: 1651039303, amount: Zatoshi(7), uuid: "gg77"),
            TransactionStateMockHelper(date: 1651039707, amount: Zatoshi(8), status: .paid, uuid: "hh88"),
            TransactionStateMockHelper(date: 1651039808, amount: Zatoshi(9), uuid: "ii99")
        ]

        let transactionList: [TransactionState] = mocked.map {
            let transaction = TransactionState.placeholder(
                amount: $0.amount,
                fee: Zatoshi(10),
                shielded: $0.shielded,
                status: $0.amount.amount > 5 ? .sending : $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return transaction
        }

        let identifiedTransactionList = IdentifiedArrayOf(uniqueElements: transactionList)

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                latestTransactionList: transactionList,
                transactionList: identifiedTransactionList
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.readTransactionsStorage = .noOp

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        await store.receive(.updateTransactionList(transactionList))
        
        await store.finish()
    }

    func testCopyToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: []
            ),
            reducer: TransactionListReducer()
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
    
    // MARK: - Expansion
    
    func testTransactionExpansion() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .paid,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.dependencies.readTransactionsStorage = .noOp
        
        store.send(.transactionExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
        }
    }
    
    func testTransactionExpansionMarkedAsRead_receiving() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .receiving,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.dependencies.readTransactionsStorage = .noOp
        
        store.send(.transactionExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
            state.transactionList[0].isMarkedAsRead = true
        }
    }
    
    func testTransactionExpansionMarkedAsRead_received() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .received,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.dependencies.readTransactionsStorage = .noOp
        
        store.send(.transactionExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
            state.transactionList[0].isMarkedAsRead = true
        }
    }
    
    func testTransactionExpansionMarkedAsRead_skippedForAlreadyMarked() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .received,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false,
            isMarkedAsRead: true
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.dependencies.readTransactionsStorage = .noOp
        
        store.send(.transactionExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
        }
    }
    
    func testAddressExpansionRequestedButTransactionIsNot() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .paid,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.send(.transactionAddressExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
        }
    }
    
    func testAddressExpansion() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .paid,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: true,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.send(.transactionAddressExpandRequested(id)) { state in
            state.transactionList[0].isAddressExpanded = true
        }
    }
    
    func testIdExpansionRequestedButTransactionIsNot() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .paid,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: false,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.send(.transactionIdExpandRequested(id)) { state in
            state.transactionList[0].isExpanded = true
        }
    }
    
    func testIdExpansion() throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        let transaction = TransactionState(
            memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
            minedHeight: BlockHeight(1),
            zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
            fee: Zatoshi(10_000),
            id: id,
            status: .paid,
            timestamp: 1699290621,
            zecAmount: Zatoshi(25_000_000),
            isAddressExpanded: false,
            isExpanded: true,
            isIdExpanded: false
        )

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: [transaction]
            ),
            reducer: TransactionListReducer()
        )
        
        store.send(.transactionIdExpandRequested(id)) { state in
            state.transactionList[0].isIdExpanded = true
        }
    }
    
    @MainActor func testSynchronizerStateChanged2Synced_MarkUnread() async throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"

        let transactionList = [
            TransactionState(
                memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
                minedHeight: BlockHeight(1),
                zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
                fee: Zatoshi(10_000),
                id: id,
                status: .received,
                timestamp: 1699290621,
                zecAmount: Zatoshi(25_793_456),
                isSentTransaction: false,
                isAddressExpanded: false,
                isExpanded: false,
                isIdExpanded: false,
                isMarkedAsRead: false
            )
        ]

        let identifiedTransactionList = IdentifiedArrayOf(uniqueElements: transactionList)

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: identifiedTransactionList
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.sdkSynchronizer.getAllTransactions = { transactionList }
        store.dependencies.readTransactionsStorage = .noOp

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        XCTAssertTrue(transactionList[0].isUnread)

        await store.receive(.updateTransactionList(transactionList)) { state in
            state.transactionList = IdentifiedArrayOf(transactionList)
            state.latestTransactionList = transactionList
            state.latestTranassctionId = id
            
            XCTAssertTrue(state.transactionList[0].isUnread)
        }
        
        await store.finish()
    }
    
    @MainActor func testSynchronizerStateChanged2Synced_MarkRead() async throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        
        let transactionList = [
            TransactionState(
                memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
                minedHeight: BlockHeight(1),
                zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
                fee: Zatoshi(10_000),
                id: id,
                status: .received,
                timestamp: 1699290621,
                zecAmount: Zatoshi(25_793_456),
                isSentTransaction: false,
                isAddressExpanded: false,
                isExpanded: false,
                isIdExpanded: false,
                isMarkedAsRead: false
            )
        ]

        let identifiedTransactionList = IdentifiedArrayOf(uniqueElements: transactionList)

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: identifiedTransactionList
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.sdkSynchronizer.getAllTransactions = { transactionList }
        store.dependencies.readTransactionsStorage = .noOp
        store.dependencies.readTransactionsStorage.readIds = { [id.redacted: true] }

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        XCTAssertTrue(transactionList[0].isUnread)

        await store.receive(.updateTransactionList(transactionList)) { state in
            state.transactionList = IdentifiedArrayOf(transactionList)
            state.latestTransactionList = transactionList
            state.latestTranassctionId = id
            state.transactionList[0].isMarkedAsRead = true
            
            XCTAssertFalse(state.transactionList[0].isUnread)
        }
        
        await store.finish()
    }
    
    @MainActor func testSynchronizerStateChanged2Synced_OldTransaction() async throws {
        let id = "t1vergg5jkp4wy8sqfasw6s5zkdpnxvfxlxh35uuc3me7dp596y2r05t6dv9htwe3pf8ksrfr8ksca2lskzja"
        
        let transactionList = [
            TransactionState(
                memos: [try! Memo(string: "Hi, pay me and I'll pay you")],
                minedHeight: BlockHeight(1),
                zAddress: "tmP3uLtGx5GPddkq8a6ddmXhqJJ3vy6tpTE",
                fee: Zatoshi(10_000),
                id: id,
                status: .received,
                timestamp: 1699290621,
                zecAmount: Zatoshi(25_793_456),
                isSentTransaction: false,
                isAddressExpanded: false,
                isExpanded: false,
                isIdExpanded: false,
                isMarkedAsRead: false
            )
        ]

        let identifiedTransactionList = IdentifiedArrayOf(uniqueElements: transactionList)

        let store = TestStore(
            initialState: TransactionListReducer.State(
                isScrollable: true,
                transactionList: identifiedTransactionList
            ),
            reducer: TransactionListReducer()
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.sdkSynchronizer.getAllTransactions = { transactionList }
        store.dependencies.readTransactionsStorage = .noOp
        store.dependencies.readTransactionsStorage.availabilityTimestamp = { 1699290622 }

        await store.send(.synchronizerStateChanged(.upToDate)) { state in
            state.latestMinedHeight = 0
        }

        XCTAssertTrue(transactionList[0].isUnread)

        await store.receive(.updateTransactionList(transactionList)) { state in
            state.transactionList = IdentifiedArrayOf(transactionList)
            state.latestTransactionList = transactionList
            state.latestTranassctionId = id
            
            XCTAssertTrue(state.transactionList[0].isUnread)
        }
        
        await store.finish()
    }
}
