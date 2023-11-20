//
//  WalletNukeTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 14.11.2023.
//

import XCTest
import Combine
import ComposableArchitecture
import Root
import Utils
import ZcashLightClientKit
@testable import secant_testnet

@MainActor
final class WalletNukeTests: XCTestCase {
    func testNukeWalletRequest() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        }
        
        await store.send(.initialization(.nukeWalletRequest)) { state in
            state.alert = AlertState.wipeRequest()
        }
        
        await store.finish()
    }
    
    func testNukeWalletFail() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        }
        
        store.dependencies.sdkSynchronizer = .noOp
        store.dependencies.sdkSynchronizer.wipe = { nil }
        store.dependencies.readTransactionsStorage = .noOp

        await store.send(.initialization(.nukeWallet))
        
        await store.receive(.nukeWalletFailed) { state in
            state.alert = AlertState.wipeFailed()
        }
        
        await store.receive(.destination(.updateDestination(.welcome))) { state in
            state.destinationState.destination = .welcome
        }
        
        await store.finish()
    }
    
    func testNukeWalletSucceeded() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer(tokenName: "ZEC", zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
        }

        var readIds: [RedactableString: Bool] = ["id1".redacted: true]
        var areKeysPresent = true
        
        store.dependencies.readTransactionsStorage = .noOp
        store.dependencies.readTransactionsStorage.readIds = { readIds }
        store.dependencies.readTransactionsStorage.nukeWallet = { readIds.removeAll() }
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletStorage.areKeysPresent = { areKeysPresent }
        store.dependencies.walletStorage.nukeWallet = { areKeysPresent = false }
        store.dependencies.mainQueue = .immediate
        store.dependencies.databaseFiles = .noOp
        
        XCTAssertEqual(readIds, ["id1".redacted: true])
        XCTAssertTrue(areKeysPresent)

        await store.send(.nukeWalletSucceeded) { state in
            var stateAfterWipe = RootReducer.State.initial
            stateAfterWipe.splashAppeared = true

            state = stateAfterWipe
        }

        XCTAssertEqual(readIds, [:])
        XCTAssertFalse(areKeysPresent)

        await store.receive(.initialization(.checkWalletInitialization))
        await store.receive(.initialization(.respondToWalletInitializationState(.uninitialized)))
        await store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.destination = .onboarding
            state.destinationState.previousDestination = .welcome
        }
        
        await store.finish()
    }
}
