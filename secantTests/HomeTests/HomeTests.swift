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

class HomeTests: XCTestCase {
    func testSynchronizerStateChanged_AnyButSynced() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
        )
        
        store.send(.synchronizerStateChanged(.progressUpdated))
        
        store.receive(.updateSynchronizerStatus)
    }

    /// When the synchronizer status change to .synced, the .updateSynchronizerStatus is called
    func testSynchronizerStateChanged_Synced() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
        ) { dependencies in
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mock
        }

        store.send(.synchronizerStateChanged(.synced))
        
        testScheduler.advance(by: 0.01)
        
        store.receive(.updateSynchronizerStatus)
    }
    
    /// The .onAppear action is important to register for the synchronizer state updates.
    /// The integration tests make sure registrations and side effects are properly implemented.
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer()
        ) {
            $0.diskSpaceChecker = .mockEmptyDisk
        }
        
        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }
        
        // expected side effects as a result of .onAppear registration
        store.receive(.updateDestination(nil))
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
        ) {
            $0.diskSpaceChecker = .mockFullDisk
        }
        
        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        // expected side effects as a result of .onAppear registration
        store.receive(.updateDestination(.notEnoughFreeDiskSpace)) { state in
            state.destination = .notEnoughFreeDiskSpace
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancles the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    @MainActor func testQuickRescan_ResetToHomeScreen() async throws {
        let homeState = HomeReducer.State(
            balanceBreakdownState: .placeholder,
            destination: .profile,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: Balance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )

        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )

        await store.send(.profile(.settings(.quickRescan))) { state in
            state.destination = nil
        }

        await store.receive(.rewindDone(true, .quickRescan))
    }

    @MainActor func testFullRescan_ResetToHomeScreen() async throws {
        let homeState = HomeReducer.State(
            balanceBreakdownState: .placeholder,
            destination: .profile,
            profileState: .placeholder,
            requestState: .placeholder,
            scanState: .placeholder,
            sendState: .placeholder,
            shieldedBalance: Balance.zero,
            synchronizerStatusSnapshot: .default,
            walletEventsState: .emptyPlaceHolder
        )

        let store = TestStore(
            initialState: homeState,
            reducer: HomeReducer()
        )

        await store.send(.profile(.settings(.fullRescan))) { state in
            state.destination = nil
        }

        await store.receive(.rewindDone(true, .fullRescan))
    }
}
