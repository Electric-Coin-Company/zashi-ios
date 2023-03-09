//
//  HomeTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.06.2022.
//

import XCTest
import ComposableArchitecture
@testable import secant_testnet
@testable import ZcashLightClientKit

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
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mockWithSnapshot(.default)
        }

        store.send(.synchronizerStateChanged(.synced))
        
        testScheduler.advance(by: 0.01)
        
        store.receive(.updateSynchronizerStatus)
    }

    func testSendButtonIsDisabledWhenSyncing() {
        let testScheduler = DispatchQueue.test

        let mockSnapshot = SyncStatusSnapshot.init(
            .syncing(
                .init(
                    startHeight: 1_700_000,
                    targetHeight: 1_800_000,
                    progressHeight: 1_770_000
                )
            )
        )

        let store = TestStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                profileState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                settingsState: .placeholder,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: mockSnapshot,
                walletConfig: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
        )

        store.dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
        store.dependencies.sdkSynchronizer = SDKSynchronizerDependency.mockWithSnapshot(mockSnapshot)

        store.send(.synchronizerStateChanged(.progressUpdated))

        testScheduler.advance(by: 0.01)

        store.receive(.updateSynchronizerStatus)

        XCTAssertTrue(store.state.isSyncing)
        XCTAssertTrue(store.state.isSendButtonDisabled)
    }

    func testSendButtonIsNotDisabledWhenSyncingWhileOnSendScreen() {
        let testScheduler = DispatchQueue.test

        let mockSnapshot = SyncStatusSnapshot.init(
            .syncing(
                .init(
                    startHeight: 1_700_000,
                    targetHeight: 1_800_000,
                    progressHeight: 1_770_000
                )
            )
        )

        let store = TestStore(
            initialState: .init(
                balanceBreakdownState: .placeholder,
                profileState: .placeholder,
                scanState: .placeholder,
                sendState: .placeholder,
                settingsState: .placeholder,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: mockSnapshot,
                walletConfig: .default,
                walletEventsState: .emptyPlaceHolder
            ),
            reducer: HomeReducer()
        )

        store.dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
        store.dependencies.sdkSynchronizer = SDKSynchronizerDependency.mockWithSnapshot(mockSnapshot)

        store.send(.updateDestination(.send)) {
            $0.destination = .send
        }

        testScheduler.advance(by: 0.01)

        store.send(.synchronizerStateChanged(.progressUpdated))

        testScheduler.advance(by: 0.01)

        store.receive(.updateSynchronizerStatus)
        
        XCTAssertTrue(store.state.isSyncing)
        XCTAssertFalse(store.state.isSendButtonDisabled)
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
        // the .onDisappear action cancels the observer of the synchronizer status change.
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
        // the .onDisappear action cancels the observer of the synchronizer status change.
        store.send(.onDisappear)
    }
}
