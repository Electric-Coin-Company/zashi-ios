//
//  ProfileTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class ProfileTests: XCTestCase {
    // swiftlint:disable line_length
    let uAddressEncoding = "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h"

    @MainActor func testSynchronizerStateChanged_AnyButSynced() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ProfileReducer()
        ) { dependencies in
            dependencies.appVersion = .mock
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mockWithSnapshot(.default)
        }

        let uAddress = try UnifiedAddress(
            encoding: uAddressEncoding,
            network: .testnet
        )

        await store.send(.onAppear) { state in
            state.addressDetailsState.uAddress = uAddress
            state.appVersion = "0.0.1"
            state.appBuild = "31"
            state.sdkVersion = "0.18.1-beta"
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
        ) {
            $0.pasteboard = testPasteboard
        }

        store.send(.copyUnifiedAddressToPastboard)
        
        XCTAssertEqual(
            testPasteboard.getString()?.data,
            uAddress.stringEncoded,
            "AddressDetails: `testCopyUnifiedAddressToPasteboard` is expected to match the input `\(uAddress.stringEncoded)`"
        )
    }
}
