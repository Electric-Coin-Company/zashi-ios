//
//  DeeplinkTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 16.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

@MainActor
class DeeplinkTests: XCTestCase {
    func testActionDeeplinkHome_SameRouteLevel() throws {
        let testEnvironment = AppEnvironment.mock
        
        var appState = AppState.placeholder
        appState.route = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.deeplinkHome) { state in
            state.route = .home
        }
    }

    func testActionDeeplinkHome_GeetingBack() throws {
        let testEnvironment = AppEnvironment.mock
        
        var appState = AppState.placeholder
        appState.route = .home
        appState.homeState.route = .send
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        store.send(.deeplinkHome) { state in
            state.route = .home
            state.homeState.route = nil
        }
    }
    
    func testActionDeeplinkSend() throws {
        let testEnvironment = AppEnvironment.mock
        
        var appState = AppState.placeholder
        appState.route = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        let amount = Zatoshi(123_000_000)
        let address = "address"
        let memo = "testing some memo"
        
        store.send(.deeplinkSend(amount, address, memo)) { state in
            state.route = .home
            state.homeState.route = .send
            state.homeState.sendState.amount = amount
            state.homeState.sendState.address = address
            state.homeState.sendState.memoState.text = memo
        }
    }

    func testDeeplinkRequest_homeURL() async throws {
        let synchronizer = TestWrappedSDKSynchronizer()
        synchronizer.updateStateChanged(.synced)
        
        let testScheduler = DispatchQueue.test

        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .live(),
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: synchronizer,
            walletStorage: .live(),
            zcashSDKEnvironment: .mainnet
        )
        
        var appState = AppState.placeholder
        appState.route = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        guard let url = URL(string: "zcash:///home") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_homeURL' URL is expected to be valid.")
        }
        
        await store.send(.deeplink(url))
        
        await store.receive(.deeplinkHome) { state in
            state.route = .home
        }
        
        await store.finish()
    }
    
    func testDeeplinkRequest_sendURL_amount() async throws {
        let synchronizer = TestWrappedSDKSynchronizer()
        synchronizer.updateStateChanged(.synced)
        
        let testScheduler = DispatchQueue.test

        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .live(),
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: synchronizer,
            walletStorage: .live(),
            zcashSDKEnvironment: .mainnet
        )
        
        var appState = AppState.placeholder
        appState.route = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        guard let url = URL(string: "zcash:///home/send?amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }
        
        await store.send(.deeplink(url))
        
        let amount = Zatoshi(123_000_000)
        let address = ""
        let memo = ""

        await store.receive(.deeplinkSend(amount, address, memo)) { state in
            state.route = .home
            state.homeState.route = .send
            state.homeState.sendState.amount = amount
            state.homeState.sendState.address = address
            state.homeState.sendState.memoState.text = memo
        }
        
        await store.finish()
    }
    
    func testDeeplinkRequest_sendURL_allFields() async throws {
        let synchronizer = TestWrappedSDKSynchronizer()
        synchronizer.updateStateChanged(.synced)
        
        let testScheduler = DispatchQueue.test

        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .live(),
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: synchronizer,
            walletStorage: .live(),
            zcashSDKEnvironment: .mainnet
        )
        
        var appState = AppState.placeholder
        appState.route = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )
        
        guard let url = URL(string: "zcash:///home/send?address=address&memo=some%20text&amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }
        
        await store.send(.deeplink(url))
        
        let amount = Zatoshi(123_000_000)
        let address = "address"
        let memo = "some text"

        await store.receive(.deeplinkSend(amount, address, memo)) { state in
            state.route = .home
            state.homeState.route = .send
            state.homeState.sendState.amount = amount
            state.homeState.sendState.address = address
            state.homeState.sendState.memoState.text = memo
        }
        
        await store.finish()
    }
}
