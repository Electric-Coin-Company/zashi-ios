//
//  ProfileTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.07.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
@testable import secant_testnet

class ProfileTests: XCTestCase {
    // swiftlint:disable line_length
    let uAddressEncoding = "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h"

    @MainActor func testSynchronizerStateChanged_AnyButSynced() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ProfileReducer()
        )

        store.dependencies.appVersion = .mock
        store.dependencies.sdkSynchronizer = .mocked()

        let uAddress = try UnifiedAddress(
            encoding: uAddressEncoding,
            network: .testnet
        )

        await store.send(.onAppear) { state in
            state.appVersion = "0.0.1"
            state.appBuild = "31"
            state.sdkVersion = "0.18.1-beta"
        }
        
        await store.receive(.uAddressChanged(uAddress)) { state in
            state.addressDetailsState.uAddress = uAddress
        }
    }
    
    func testCopyUnifiedAddressToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: ProfileReducer.State(
                addressDetailsState: AddressDetailsReducer.State(uAddress: uAddress)
            ),
            reducer: ProfileReducer()
        )

        store.dependencies.pasteboard = testPasteboard

        store.send(.copyUnifiedAddressToPastboard)
        
        XCTAssertEqual(
            testPasteboard.getString()?.data,
            uAddress.stringEncoded,
            "AddressDetails: `testCopyUnifiedAddressToPasteboard` is expected to match the input `\(uAddress.stringEncoded)`"
        )
    }
}
