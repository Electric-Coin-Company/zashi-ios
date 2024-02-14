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
                scanState: .initial,
                shieldedBalance: .zero,
                synchronizerStatusSnapshot: mockSnapshot,
                syncProgressState: .initial,
                transactionListState: .initial,
                walletConfig: .initial
            )
        ) {
            HomeReducer()
        }

        XCTAssertTrue(store.state.isSendButtonDisabled)
    }
    
    /// The .onAppear action is important to register for the synchronizer state updates.
    /// The integration tests make sure registrations and side effects are properly implemented.
    @MainActor func testOnAppear() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            HomeReducer()
        }

        store.dependencies.mainQueue = .immediate
        store.dependencies.diskSpaceChecker = .mockEmptyDisk
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.reviewRequest = .noOp

        await store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        var syncState: SynchronizerState = .zero
        syncState.syncStatus = .unprepared
        let snapshot = SyncStatusSnapshot.snapshotFor(state: syncState.syncStatus)

        // expected side effects as a result of .onAppear registration
        await store.receive(.updateDestination(nil))
        await store.receive(.synchronizerStateChanged(.zero)) { state in
            state.synchronizerStatusSnapshot = snapshot
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
        
        await store.finish()
    }

    @MainActor func testOnAppear_notEnoughSpaceOnDisk() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            HomeReducer()
        }

        store.dependencies.diskSpaceChecker = .mockFullDisk
        store.dependencies.reviewRequest = .noOp

        await store.send(.onAppear) { state in
            state.requiredTransactionConfirmations = 10
        }

        // expected side effects as a result of .onAppear registration
        await store.receive(.updateDestination(.notEnoughFreeDiskSpace)) { state in
            state.destination = .notEnoughFreeDiskSpace
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
        
        await store.finish()
    }

    @MainActor func testSynchronizerErrorBringsUpAlert() async {
        let testError = ZcashError.synchronizerNotPrepared
        let errorSnapshot = SyncStatusSnapshot.snapshotFor(
            state: .error(testError)
        )

        var state = SynchronizerState.zero
        state.syncStatus = .error(testError)
        
        let store = TestStore(
            initialState: .initial
        ) {
            HomeReducer()
        }

        await store.send(.synchronizerStateChanged(state)) { state in
            state.synchronizerStatusSnapshot = errorSnapshot
            state.migratingDatabase = false
        }

        await store.receive(.showSynchronizerErrorAlert(testError))
        
        await store.finish()
    }
    
    @MainActor func testRestoreWalletSubscription() async throws {
        var initialState = HomeReducer.State.initial
        initialState.isRestoringWallet = false

        let store = TestStore(
            initialState: initialState
        ) {
            HomeReducer()
        }

        store.dependencies.restoreWalletStorage = .noOp
        store.dependencies.restoreWalletStorage.value = {
            AsyncStream { continuation in
                continuation.yield(true)
                continuation.finish()
            }
        }
        
        await store.send(.restoreWalletTask)
        
        await store.receive(.restoreWalletValue(true)) { state in
            state.isRestoringWallet = true
        }
        
        await store.finish()
    }
}
