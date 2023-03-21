//
//  BalanceBreakdownTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 15.08.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit
import Combine

class BalanceBreakdownTests: XCTestCase {
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
        )
        
        store.dependencies.sdkSynchronizer = .mocked()
        store.dependencies.mainQueue = .immediate
        store.dependencies.numberFormatter = .noOp
        
        store.send(.onAppear)
        
        // expected side effects as a result of .onAppear registration
        store.receive(.synchronizerStateChanged(.zero))
        store.receive(.updateLatestBlock) { state in
            state.latestBlock = "nil"
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    @MainActor func testShieldFundsSucceed() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
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
            state.alert = AlertState(
                title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.title),
                message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Success.message),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
    }

    @MainActor func testShieldFundsFails() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
        )

        store.dependencies.sdkSynchronizer = .mocked(shieldFunds: { _, _, _ in throw SynchronizerError.criticalError })
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.shieldFunds) { state in
            state.shieldingFunds = true
        }
        await store.receive(.shieldFundsFailure(SynchronizerError.criticalError.localizedDescription)) { state in
            state.shieldingFunds = false
            state.alert = AlertState(
                title: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.title),
                message: TextState(L10n.BalanceBreakdown.Alert.ShieldFunds.Failure.message(SynchronizerError.criticalError.localizedDescription)),
                dismissButton: .default(TextState(L10n.General.ok), action: .send(.dismissAlert))
            )
        }

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        await store.send(.onDisappear)
    }

    @MainActor func testShieldFundsButtonDisabledWhenNoShieldableFunds() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
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
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            ),
            reducer: BalanceBreakdownReducer()
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
                transparentBalance: Balance(
                    WalletBalance(
                        verified: Zatoshi(1_000_000),
                        total: Zatoshi(1_000_000)
                    )
                )
            ),
            reducer: BalanceBreakdownReducer()
        )

        XCTAssertTrue(store.state.shieldingFunds)
        XCTAssertTrue(store.state.isShieldableBalanceAvailable)
        XCTAssertTrue(store.state.isShieldingButtonDisabled)
    }
}
