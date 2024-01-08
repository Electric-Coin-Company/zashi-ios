//
//  SyncProgressTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.12.2023.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import SyncProgress
import Models
@testable import secant_testnet

@MainActor
final class SyncProgressTests: XCTestCase {
    func testSyncingData() async throws {
        let store = TestStore(
            initialState: SyncProgressReducer.State(
                lastKnownSyncPercentage: 0.0,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513))
            )
        ) {
            SyncProgressReducer()
        }
        
        XCTAssertTrue(store.state.isSyncing)
        XCTAssertEqual(store.state.syncingPercentage, 0.513 * 0.999)
    }
    
    func testlastKnownSyncingPercentage_Zero() async throws {
        let store = TestStore(
            initialState: SyncProgressReducer.State(
                lastKnownSyncPercentage: 0.0,
                synchronizerStatusSnapshot: .placeholder
            )
        ) {
            SyncProgressReducer()
        }

        XCTAssertEqual(store.state.lastKnownSyncPercentage, 0)
        XCTAssertEqual(store.state.syncingPercentage, 0)
    }
    
    func testlastKnownSyncingPercentage_MoreThanZero() async throws {
        let store = TestStore(
            initialState: SyncProgressReducer.State(
                lastKnownSyncPercentage: 0.15,
                synchronizerStatusSnapshot: .placeholder
            )
        ) {
            SyncProgressReducer()
        }

        XCTAssertEqual(store.state.lastKnownSyncPercentage, 0.15)
        XCTAssertEqual(store.state.syncingPercentage, 0.15)
    }
    
    func testlastKnownSyncingPercentage_FromSyncedState() async throws {
        let store = TestStore(
            initialState: SyncProgressReducer.State(
                lastKnownSyncPercentage: 0.15,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513))
            )
        ) {
            SyncProgressReducer()
        }

        var syncState: SynchronizerState = .zero
        syncState.syncStatus = .upToDate
        let snapshot = SyncStatusSnapshot.snapshotFor(state: syncState.syncStatus)
        
        await store.send(.synchronizerStateChanged(syncState)) { state in
            state.synchronizerStatusSnapshot = snapshot
            state.syncStatusMessage = "Synced"
            state.lastKnownSyncPercentage = 1.0
        }
    }
    
    func testlastKnownSyncingPercentage_FromSyncingState() async throws {
        let store = TestStore(
            initialState: SyncProgressReducer.State(
                lastKnownSyncPercentage: 0.15,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513))
            )
        ) {
            SyncProgressReducer()
        }

        var syncState: SynchronizerState = .zero
        syncState.syncStatus = .syncing(0.545)
        let snapshot = SyncStatusSnapshot.snapshotFor(state: syncState.syncStatus)
        
        await store.send(.synchronizerStateChanged(syncState)) { state in
            state.synchronizerStatusSnapshot = snapshot
            state.syncStatusMessage = "Syncing"
            state.lastKnownSyncPercentage = 0.545
        }
    }
}
