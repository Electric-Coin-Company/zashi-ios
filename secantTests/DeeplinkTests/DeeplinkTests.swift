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
        var appState = AppReducer.State.placeholder
        appState.route = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
        )
        
        store.send(.deeplinkHome) { state in
            state.route = .home
        }
    }

    func testActionDeeplinkHome_GeetingBack() throws {
        var appState = AppReducer.State.placeholder
        appState.route = .home
        appState.homeState.route = .send
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
        )
        
        store.send(.deeplinkHome) { state in
            state.route = .home
            state.homeState.route = nil
        }
    }
    
    func testActionDeeplinkSend() throws {
        var appState = AppReducer.State.placeholder
        appState.route = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
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

    func testHomeURLParsing() throws {
        guard let url = URL(string: "zcash:///home") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_homeURL' URL is expected to be valid.")
        }

        let result = try Deeplink().resolveDeeplinkURL(url, isValidZcashAddress: { _ in false })
        
        XCTAssertEqual(result, Deeplink.Route.home)
    }

    func testDeeplinkRequest_Received_Home() async throws {
        var appState = AppReducer.State.placeholder
        appState.route = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
        ) { dependencies in
            dependencies.deeplink = DeeplinkClient(
                resolveDeeplinkURL: { _, _ in Deeplink.Route.home }
            )
            let synchronizer = NoopSDKSynchronizer()
            synchronizer.updateStateChanged(.synced)
            dependencies.sdkSynchronizer = synchronizer
        }

        guard let url = URL(string: "zcash:///home") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_homeURL' URL is expected to be valid.")
        }
        
        _ = await store.send(.deeplink(url))
        
        await store.receive(.deeplinkHome) { state in
            state.route = .home
        }
        
        await store.finish()
    }

    func testsendURLParsing() throws {
        guard let url = URL(string: "zcash:///home/send?address=address&memo=some%20text&amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }

        let result = try Deeplink().resolveDeeplinkURL(url, isValidZcashAddress: { _ in false })
        
        XCTAssertEqual(result, Deeplink.Route.send(amount: 123_000_000, address: "address", memo: "some text"))
    }
    
    func testDeeplinkRequest_Received_Send() async throws {
        let synchronizer = NoopSDKSynchronizer()
        synchronizer.updateStateChanged(.synced)
        
        var appState = AppReducer.State.placeholder
        appState.route = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
        ) { dependencies in
            dependencies.deeplink = DeeplinkClient(
                resolveDeeplinkURL: { _, _ in Deeplink.Route.send(amount: 123_000_000, address: "address", memo: "some text") }
            )
            dependencies.sdkSynchronizer = synchronizer
        }
        
        guard let url = URL(string: "zcash:///home/send?address=address&memo=some%20text&amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }

        _ = await store.send(.deeplink(url))
        
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
