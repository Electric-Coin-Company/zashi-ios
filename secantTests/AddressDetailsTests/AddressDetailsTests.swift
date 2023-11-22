//
//  AddressDetailsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.01.2023.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Pasteboard
import AddressDetails
@testable import secant_testnet

@MainActor
class AddressDetailsTests: XCTestCase {
    // swiftlint:disable line_length
    let uAddressEncoding = "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h"
    
    func testCopyTransparentAddressToPasteboard() async throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: AddressDetailsReducer.State(uAddress: uAddress)
        ) {
            AddressDetailsReducer()
        }
        
        store.dependencies.pasteboard = testPasteboard

        await store.send(.copyTransparentAddressToPastboard)
        
        let expectedAddress = try uAddress.transparentReceiver().stringEncoded
        
        XCTAssertEqual(
            testPasteboard.getString()?.data,
            expectedAddress,
            "AddressDetails: `testCopyTransparentAddressToPasteboard` is expected to match the input `\(expectedAddress)`"
        )
        
        await store.finish()
    }
    
    func testCopyUnifiedAddressToPasteboard() async throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: AddressDetailsReducer.State(uAddress: uAddress)
        ) {
            AddressDetailsReducer()
        }
        
        store.dependencies.pasteboard = testPasteboard

        await store.send(.copyUnifiedAddressToPastboard)
        
        XCTAssertEqual(
            testPasteboard.getString()?.data,
            uAddress.stringEncoded,
            "AddressDetails: `testCopyUnifiedAddressToPasteboard` is expected to match the input `\(uAddress.stringEncoded)`"
        )
        
        await store.finish()
    }
}
