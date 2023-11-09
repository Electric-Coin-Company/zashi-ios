//
//  HomeTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.06.2022.
//

import Combine
import XCTest
import ComposableArchitecture
import Utils
import Generated
import Models
import Home
@testable import secant_testnet
@testable import ZcashLightClientKit

class HomeTests: XCTestCase {
    func testSendButtonIsDisabledWhenSyncing() {
        let mockSnapshot = SyncStatusSnapshot.init(
            .syncing(0.7)
        )

        let store = TestStore(
            initialState: .init(
                scanState: .placeholder,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: mockSnapshot,
                walletConfig: .default,
                transactionListState: .emptyPlaceHolder
            ),
            reducer: HomeReducer(networkType: .testnet)
        )

        XCTAssertTrue(store.state.isSendButtonDisabled)
    }
    
    /// The .onAppear action is important to register for the synchronizer state updates.
    /// The integration tests make sure registrations and side effects are properly implemented.
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer(networkType: .testnet)
        )

        store.dependencies.mainQueue = .immediate
        store.dependencies.diskSpaceChecker = .mockEmptyDisk
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.reviewRequest = .noOp

        store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        // expected side effects as a result of .onAppear registration
        store.receive(.updateDestination(nil))
        store.receive(.synchronizerStateChanged(.zero))

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    func testOnAppear_notEnoughSpaceOnDisk() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer(networkType: .testnet)
        )

        store.dependencies.diskSpaceChecker = .mockFullDisk
        store.dependencies.reviewRequest = .noOp

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

    func testSynchronizerErrorBringsUpAlert() {
        let testError = ZcashError.synchronizerNotPrepared
        let errorSnapshot = SyncStatusSnapshot.snapshotFor(
            state: .error(testError)
        )

        var state = SynchronizerState.zero
        state.syncStatus = .error(testError)
        
        let store = TestStore(
            initialState: .placeholder,
            reducer: HomeReducer(networkType: .testnet)
        )

        store.send(.synchronizerStateChanged(state)) { state in
            state.synchronizerStatusSnapshot = errorSnapshot
            state.migratingDatabase = false
        }

        store.receive(.showSynchronizerErrorAlert(testError))
    }
}
