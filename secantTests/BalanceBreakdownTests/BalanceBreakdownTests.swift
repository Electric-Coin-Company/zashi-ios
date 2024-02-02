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
                shieldedBalance: .zero,
                syncProgressState: .initial,
                totalBalance: .zero,
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
                shieldedBalance: .zero,
                syncProgressState: .initial,
                totalBalance: .zero,
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
    
    func testRestoreWalletSubscription() async throws {
        var initialState = BalanceBreakdownReducer.State.initial
        initialState.isRestoringWallet = false
        
        let store = TestStore(
            initialState: initialState
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
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
    
    func testShowHintbox() async throws {
        var initialState = BalanceBreakdownReducer.State.initial
        initialState.isHintBoxVisible = false

        let store = TestStore(
            initialState: initialState
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }
        
        await store.send(.updateHintBoxVisibility(true)) { state in
            state.isHintBoxVisible = true
        }
        
        await store.finish()
    }
    
    func testHideHintbox() async throws {
        var initialState = BalanceBreakdownReducer.State.initial
        initialState.isHintBoxVisible = true
        
        let store = TestStore(
            initialState: initialState
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
        }
        
        await store.send(.updateHintBoxVisibility(false)) { state in
            state.isHintBoxVisible = false
        }
        
        await store.finish()
    }
}
