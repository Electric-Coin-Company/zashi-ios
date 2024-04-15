//
//  RestoreWalletTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 04.01.2024.
//

import XCTest
import Combine
import ComposableArchitecture
import Root
import Utils
import ZcashLightClientKit
@testable import secant_testnet

@MainActor
final class RestoreWalletTests: XCTestCase {
    func testIsRestoringWallet() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            RootReducer()
        }
        
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .noOp
        store.dependencies.restoreWalletStorage = .noOp
        store.dependencies.restoreWalletStorage.updateValue = { value in
            XCTAssertTrue(value)
        }
        store.dependencies.sdkSynchronizer = .noOp
        store.dependencies.walletStorage = .noOp
        store.dependencies.userDefaults = .noOp

        await store.send(.onboarding(.importWallet(.initializeSDK))) { state in
            state.isRestoringWallet = true
        }
        
        await store.receive(.initialization(.initializeSDK(.restoreWallet)))
        
        await store.receive(.initialization(.initializationSuccessfullyDone(nil)))

        await store.receive(.initialization(.registerForSynchronizersUpdate))

        await store.finish()
    }
    
    func testIsRestoringWalletFinished() async throws {
        var state = RootReducer.State.initial
        state.isRestoringWallet = true
        
        let store = TestStore(
            initialState: state
        ) {
            RootReducer()
        }
        
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .noOp
        store.dependencies.restoreWalletStorage = .noOp
        store.dependencies.restoreWalletStorage.updateValue = { value in
            XCTAssertFalse(value)
        }
        store.dependencies.sdkSynchronizer = .noOp
        store.dependencies.walletStorage = .noOp
        store.dependencies.userDefaults = .noOp

        var syncState: SynchronizerState = .zero
        syncState.syncStatus = .upToDate

        await store.send(.synchronizerStateChanged(syncState.redacted))
        
        await store.receive(.initialization(.checkRestoreWalletFlag(syncState.syncStatus))) { state in
            state.isRestoringWallet = false
        }

        await store.finish()
    }
}
