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
@testable import secant_testnet

class BalanceBreakdownTests: XCTestCase {
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )
        
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.mainQueue = .immediate
        store.dependencies.numberFormatter = .noOp
        
        store.send(.onAppear)
        
        // expected side effects as a result of .onAppear registration
        store.receive(.synchronizerStateChanged(.zero))
        store.receive(.updateLatestBlock) { state in
            state.latestBlock = ""
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    @MainActor func testShieldFundsSucceed() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )

        store.dependencies.sdkSynchronizer = .mock
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.shieldFunds) { state in
            state.shieldingFunds = true
        }
        await store.receive(.shieldFundsSuccess) { state in
            state.shieldingFunds = false
            state.alert = AlertState.shieldFundsSuccess()
        }
        
        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
    }

    @MainActor func testShieldFundsFails() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )

        store.dependencies.sdkSynchronizer = .mocked(shieldFunds: { _, _, _ in throw ZcashError.synchronizerNotPrepared })
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.shieldFunds) { state in
            state.shieldingFunds = true
        }
        await store.receive(.shieldFundsFailure(ZcashError.synchronizerNotPrepared)) { state in
            state.shieldingFunds = false
            state.alert = AlertState.shieldFundsFailure(ZcashError.synchronizerNotPrepared)
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
    }

    @MainActor func testShieldFundsButtonDisabledWhenNoShieldableFunds() async throws {
        let store = TestStore(
            initialState: .initial,
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )

        XCTAssertFalse(store.state.shieldingFunds)
        XCTAssertFalse(store.state.isShieldableBalanceAvailable)
        XCTAssertTrue(store.state.isShieldingButtonDisabled)
    }

    @MainActor func testShieldFundsButtonEnabledWhenShieldableFundsAvailable() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                latestBlock: L10n.General.unknown,
                shieldedBalance: Balance.zero,
                shieldingFunds: false,
                synchronizerStatusSnapshot: .initial,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            ),
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )

        XCTAssertFalse(store.state.shieldingFunds)
        XCTAssertTrue(store.state.isShieldableBalanceAvailable)
        XCTAssertFalse(store.state.isShieldingButtonDisabled)
    }

    @MainActor func testShieldFundsButtonDisabledWhenShieldableFundsAvailableAndShielding() async throws {
        let store = TestStore(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                latestBlock: L10n.General.unknown,
                shieldedBalance: Balance.zero,
                shieldingFunds: true,
                synchronizerStatusSnapshot: .initial,
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            ),
            reducer: BalanceBreakdownReducer(networkType: .testnet)
        )

        XCTAssertTrue(store.state.shieldingFunds)
        XCTAssertTrue(store.state.isShieldableBalanceAvailable)
        XCTAssertTrue(store.state.isShieldingButtonDisabled)
    }
}
