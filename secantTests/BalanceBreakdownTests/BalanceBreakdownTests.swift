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

class BalanceBreakdownTests: XCTestCase {
    func testOnAppear() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
        )
        
        store.send(.onAppear)
        
        // expected side effects as a result of .onAppear registration
        store.receive(.synchronizerStateChanged(.unknown))
        store.receive(.updateSynchronizerStatus)
        store.receive(.updateLatestBlock)

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancels the observer of the synchronizer status change.
        store.send(.onDisappear)
    }

    @MainActor func testShieldFundsSucceed() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
        )

        store.dependencies.sdkSynchronizer = MockSDKSynchronizerClient()
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

        store.dependencies.sdkSynchronizer = NoopSDKSynchronizer()
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
}
