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
    func testActionDeeplinkHome_SameDestinationLevel() throws {
        var appState = RootReducer.State.placeholder
        appState.destinationState.destination = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        )
        
        store.send(.destination(.deeplinkHome)) { state in
            state.destinationState.destination = .home
        }
    }

    func testActionDeeplinkHome_GeetingBack() throws {
        var appState = RootReducer.State.placeholder
        appState.destinationState.destination = .home
        appState.homeState.destination = .send
        
        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        )
        
        store.send(.destination(.deeplinkHome)) { state in
            state.destinationState.destination = .home
            state.homeState.destination = nil
        }
    }
    
    func testActionDeeplinkSend() throws {
        var appState = RootReducer.State.placeholder
        appState.destinationState.destination = .welcome
        
        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        )
        
        let amount = Zatoshi(123_000_000)
        let address = "address"
        let memo = "testing some memo"
        
        store.send(.destination(.deeplinkSend(amount, address, memo))) { state in
            state.destinationState.destination = .home
            state.homeState.destination = .send
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
        
        XCTAssertEqual(result, Deeplink.Destination.home)
    }

    func testDeeplinkRequest_Received_Home() async throws {
        var appState = RootReducer.State.placeholder
        appState.destinationState.destination = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.deeplink = DeeplinkClient(
                resolveDeeplinkURL: { _, _ in Deeplink.Destination.home }
            )
            let synchronizer = NoopSDKSynchronizer()
            synchronizer.updateStateChanged(.synced)
            dependencies.sdkSynchronizer = synchronizer
        }

        guard let url = URL(string: "zcash:///home") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_homeURL' URL is expected to be valid.")
        }
        
        _ = await store.send(.destination(.deeplink(url)))
        
        await store.receive(.destination(.deeplinkHome)) { state in
            state.destinationState.destination = .home
        }
        
        await store.finish()
    }

    func testsendURLParsing() throws {
        guard let url = URL(string: "zcash:///home/send?address=address&memo=some%20text&amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }

        let result = try Deeplink().resolveDeeplinkURL(url, isValidZcashAddress: { _ in false })
        
        XCTAssertEqual(result, Deeplink.Destination.send(amount: 123_000_000, address: "address", memo: "some text"))
    }
    
    func testDeeplinkRequest_Received_Send() async throws {
        let synchronizer = NoopSDKSynchronizer()
        synchronizer.updateStateChanged(.synced)
        
        var appState = RootReducer.State.placeholder
        appState.destinationState.destination = .welcome
        appState.appInitializationState = .initialized
        
        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.deeplink = DeeplinkClient(
                resolveDeeplinkURL: { _, _ in Deeplink.Destination.send(amount: 123_000_000, address: "address", memo: "some text") }
            )
            dependencies.sdkSynchronizer = synchronizer
        }
        
        guard let url = URL(string: "zcash:///home/send?address=address&memo=some%20text&amount=123000000") else {
            return XCTFail("Deeplink: 'testDeeplinkRequest_sendURL_amount' URL is expected to be valid.")
        }

        _ = await store.send(.destination(.deeplink(url)))
        
        let amount = Zatoshi(123_000_000)
        let address = "address"
        let memo = "some text"

        await store.receive(.destination(.deeplinkSend(amount, address, memo))) { state in
            state.destinationState.destination = .home
            state.homeState.destination = .send
            state.homeState.sendState.amount = amount
            state.homeState.sendState.address = address
            state.homeState.sendState.memoState.text = memo
        }
        
        await store.finish()
    }
}
