//
//  BalanceBreakdownTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 15.08.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Combine
import Utils
import Generated
import BalanceBreakdown
import Models
@testable import secant_testnet

@MainActor
class BalanceBreakdownTests: XCTestCase {
    func testOnAppear() async throws {
        let store = TestStore(
            initialState: .placeholder
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }
        
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.mainQueue = .immediate
        store.dependencies.numberFormatter = .noOp
        
        await store.send(.onAppear)
        
        // expected side effects as a result of .onAppear registration
        await store.receive(.synchronizerStateChanged(.zero))

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
        
        await store.finish()
    }

    func testShieldFundsFails() async throws {
        let store = TestStore(
            initialState: .placeholder
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        store.dependencies.sdkSynchronizer = .mocked(shieldFunds: { _, _, _ in throw ZcashError.synchronizerNotPrepared })
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.shieldFunds) { state in
            state.isShieldingFunds = true
        }
        await store.receive(.shieldFundsFailure(ZcashError.synchronizerNotPrepared)) { state in
            state.isShieldingFunds = false
            state.alert = AlertState.shieldFundsFailure(ZcashError.synchronizerNotPrepared)
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
        
        await store.finish()
    }

    func testShieldFundsButtonDisabledWhenNoShieldableFunds() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertFalse(store.state.isShieldingFunds)
        XCTAssertFalse(store.state.isShieldableBalanceAvailable)
        XCTAssertTrue(store.state.isShieldingButtonDisabled)
    }

    func testShieldFundsButtonEnabledWhenShieldableFundsAvailable() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: false,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .initial,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertFalse(store.state.isShieldingFunds)
        XCTAssertTrue(store.state.isShieldableBalanceAvailable)
        XCTAssertFalse(store.state.isShieldingButtonDisabled)
    }

    func testShieldFundsButtonDisabledWhenShieldableFundsAvailableAndShielding() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .initial,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertTrue(store.state.isShieldingFunds)
        XCTAssertTrue(store.state.isShieldableBalanceAvailable)
        XCTAssertTrue(store.state.isShieldingButtonDisabled)
    }
    
    func testSyncingData() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513)),
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertTrue(store.state.isSyncing)
        XCTAssertEqual(store.state.syncingPercentage, 0.513 * 0.999)
    }
    
    func testlastKnownSyncingPercentage_Zero() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .placeholder,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertEqual(store.state.lastKnownSyncPercentage, 0)
        XCTAssertEqual(store.state.syncingPercentage, 0)
    }
    
    func testlastKnownSyncingPercentage_MoreThanZero() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                lastKnownSyncPercentage: 0.15,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .placeholder,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }

        XCTAssertEqual(store.state.lastKnownSyncPercentage, 0.15)
        XCTAssertEqual(store.state.syncingPercentage, 0.15)
    }
    
    func testlastKnownSyncingPercentage_FromSyncedState() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                lastKnownSyncPercentage: 0.15,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513)),
                transparentBalance: .zero
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
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
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: true,
                lastKnownSyncPercentage: 0.15,
                pendingTransactions: .zero,
                shieldedBalance: Balance.zero,
                synchronizerStatusSnapshot: .snapshotFor(state: .syncing(0.513)),
                transparentBalance: .zero
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
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
