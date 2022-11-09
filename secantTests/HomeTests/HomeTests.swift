//
//  HomeTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

// swiftlint:disable type_body_length
class HomeTests: XCTestCase {
    func testSynchronizerStateChanged_AnyButSynced() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
        )
        
        store.send(.synchronizerStateChanged(.downloading))
        
        store.receive(.updateSynchronizerStatus)
    }

    /// When the synchronizer status change to .synced, several things happen
    /// 1. the .updateSynchronizerStatus is called
    /// 2. the side effect to update the transactions history is called
    func testSynchronizerStateChanged_Synced() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
                .dependency(\.mainQueue, testScheduler.eraseToAnyScheduler())
        )
        
        store.send(.synchronizerStateChanged(.synced))
        
        testScheduler.advance(by: 0.01)
        
        // ad 1.
        store.receive(.updateSynchronizerStatus)

        // ad 2.
        let transactionsHelper: [TransactionStateMockHelper] = [
            TransactionStateMockHelper(date: 1651039202, amount: Zatoshi(1), status: .paid(success: false), uuid: "1"),
            TransactionStateMockHelper(date: 1651039101, amount: Zatoshi(2), uuid: "2"),
            TransactionStateMockHelper(date: 1651039000, amount: Zatoshi(3), status: .paid(success: true), uuid: "3"),
            TransactionStateMockHelper(date: 1651039505, amount: Zatoshi(4), uuid: "4"),
            TransactionStateMockHelper(date: 1651039404, amount: Zatoshi(5), uuid: "5")
        ]
        let walletEvents: [WalletEvent] = transactionsHelper.map {
            let transaction = TransactionState.placeholder(
                amount: $0.amount,
                fee: Zatoshi(10),
                shielded: $0.shielded,
                status: $0.status,
                timestamp: $0.date,
                uuid: $0.uuid
            )
            return WalletEvent(id: transaction.id, state: .send(transaction), timestamp: transaction.timestamp)
        }
        
        store.receive(.updateWalletEvents(walletEvents))
    }
    
    func testWalletEventsPartial_to_FullDrawer() throws {
        let homeState = HomeReducer.State(
            balanceBreakdownState: .placeholder,
            drawerOverlay: .partial,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: WalletBalance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )
        
        store.send(.walletEvents(.updateRoute(.all))) { state in
            state.walletEventsState.route = .all
        }
                   
        store.receive(.updateDrawer(.full)) { state in
            state.drawerOverlay = .full
            state.walletEventsState.isScrollable = true
        }
    }
    
    func testWalletEventsFull_to_PartialDrawer() throws {
        let homeState = HomeReducer.State(
            balanceBreakdownState: .placeholder,
            drawerOverlay: .full,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: WalletBalance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )
        
        store.send(.walletEvents(.updateRoute(.latest))) { state in
            state.walletEventsState.route = .latest
        }
                   
        store.receive(.updateDrawer(.partial)) { state in
            state.drawerOverlay = .partial
            state.walletEventsState.isScrollable = false
        }
    }
    
    /// The .onAppear action is important to register for the synchronizer state updates.
    /// The integration tests make sure registrations and side effects are properly implemented.
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
        )
        
        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }
        
        // expected side effects as a result of .onAppear registration
        store.receive(.updateRoute(nil))
        store.receive(.synchronizerStateChanged(.unknown))
        store.receive(.updateSynchronizerStatus)

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancles the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    func testOnAppear_notEnoughSpaceOnDisk() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
                .dependency(\.diskSpaceChecker, .mockFullDisk)
        )

        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        // expected side effects as a result of .onAppear registration
        store.receive(.updateRoute(.notEnoughFreeDiskSpace)) { state in
            state.route = .notEnoughFreeDiskSpace
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancles the observer of the synchronizer status change.
        store.send(.onDisappear)
    }
    
    func testQuickRescan_ResetToHomeScreen() throws {
        let homeState = HomeReducer.State(
            route: .profile,
            balanceBreakdownState: .placeholder,
            drawerOverlay: .full,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: WalletBalance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )
        
        store.send(.profile(.settings(.quickRescan))) { state in
            state.route = nil
        }
    }
    
    func testFullRescan_ResetToHomeScreen() throws {
        let homeState = HomeReducer.State(
            route: .profile,
            balanceBreakdownState: .placeholder,
            drawerOverlay: .full,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: WalletBalance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )
        
        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )
        
        store.send(.profile(.settings(.fullRescan))) { state in
            state.route = nil
        }
    }
}
