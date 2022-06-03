//
//  HomeTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class HomeTests: XCTestCase {
    func testSynchronizerStateChanged_AnyButSynced() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = HomeEnvironment(
            audioServices: .silent,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .throwing
        )
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer.default,
            environment: testEnvironment
        )
        
        store.send(.synchronizerStateChanged(.downloading))
        
        store.receive(.updateSynchronizerStatus)
    }

    /// When the synchronizer status change to .synced, several things happen
    /// 1. the .updateSynchronizerStatus is called
    /// 2. the side effect to update the transactions history is called
    /// 3. the side effect to update the balance is called
    func testSynchronizerStateChanged_Synced() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = HomeEnvironment(
            audioServices: .silent,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .throwing
        )
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer.default,
            environment: testEnvironment
        )
        
        store.send(.synchronizerStateChanged(.synced))
        
        testScheduler.advance(by: 0.01)
        
        // ad 1.
        store.receive(.updateSynchronizerStatus)

        // ad 2.
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
        
        store.receive(.updateTransactions(transactions))
        
        // ad 3.
        let balance = Balance(verified: 12_345_000, total: 12_345_000)

        store.receive(.updateBalance(balance)) { state in
            state.verifiedBalance = Zatoshi(amount: 12_345_000)
            state.totalBalance = Zatoshi(amount: 12_345_000)
        }
    }
    
    func testTransactionHistoryPartial_to_FullDrawer() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = HomeEnvironment(
            audioServices: .silent,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .throwing
        )
        
        let homeState = HomeState(
            drawerOverlay: .partial,
            profileState: .placeholder,
            requestState: .placeholder,
            sendState: .placeholder,
            scanState: .placeholder,
            synchronizerStatus: "",
            totalBalance: Zatoshi.zero,
            transactionHistoryState: .emptyPlaceHolder,
            verifiedBalance: Zatoshi.zero
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionHistory(.updateRoute(.all))) { state in
            state.transactionHistoryState.route = .all
        }
                   
        store.receive(.updateDrawer(.full)) { state in
            state.drawerOverlay = .full
            state.transactionHistoryState.isScrollable = true
        }
    }
    
    func testTransactionHistoryFull_to_PartialDrawer() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = HomeEnvironment(
            audioServices: .silent,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .throwing
        )
        
        let homeState = HomeState(
            drawerOverlay: .full,
            profileState: .placeholder,
            requestState: .placeholder,
            sendState: .placeholder,
            scanState: .placeholder,
            synchronizerStatus: "",
            totalBalance: Zatoshi.zero,
            transactionHistoryState: .emptyPlaceHolder,
            verifiedBalance: Zatoshi.zero
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer.default,
            environment: testEnvironment
        )
        
        store.send(.transactionHistory(.updateRoute(.latest))) { state in
            state.transactionHistoryState.route = .latest
        }
                   
        store.receive(.updateDrawer(.partial)) { state in
            state.drawerOverlay = .partial
            state.transactionHistoryState.isScrollable = false
        }
    }
    
    /// The .onAppear action is important to register for the synchronizer state updates.
    /// The integration tests make sure registrations and side effects are properly implemented.
    func testOnAppear() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = HomeEnvironment(
            audioServices: .silent,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .throwing
        )
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer.default,
            environment: testEnvironment
        )
        
        store.send(.onAppear)
        
        testScheduler.advance(by: 0.01)
        
        // expected side effects as a result of .onAppear registration
        store.receive(.synchronizerStateChanged(.unknown))
        store.receive(.updateSynchronizerStatus)
        
        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancles the observer of the synchronizer status change.
        store.send(.onDisappear)
    }
}
