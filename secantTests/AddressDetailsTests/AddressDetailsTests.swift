//
//  AddressDetailsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.01.2023.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class AddressDetailsTests: XCTestCase {
    // swiftlint:disable line_length
    let uAddressEncoding = "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h"
    
    func testCopySaplingAddressToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: AddressDetailsReducer.State(uAddress: uAddress),
            reducer: AddressDetailsReducer()
        ) {
            $0.pasteboard = testPasteboard
        }

        store.send(.copySaplingAddressToPastboard)
        
        let expectedAddress = uAddress.saplingReceiver()?.stringEncoded ?? "could not extract sapling receiver from UA"
        
        XCTAssertEqual(
            testPasteboard.getString(),
            expectedAddress,
            "AddressDetails: `testCopySaplingAddressToPasteboard` is expected to match the input `\(expectedAddress)`"
        )
    }
    
    func testCopyTransparentAddressToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: AddressDetailsReducer.State(uAddress: uAddress),
            reducer: AddressDetailsReducer()
        ) {
            $0.pasteboard = testPasteboard
        }

        store.send(.copyTransparentAddressToPastboard)
        
        let expectedAddress = uAddress.transparentReceiver()?.stringEncoded ?? "could not extract transparent receiver from UA"
        
        XCTAssertEqual(
            testPasteboard.getString(),
            expectedAddress,
            "AddressDetails: `testCopyTransparentAddressToPasteboard` is expected to match the input `\(expectedAddress)`"
        )
    }
    
    func testCopyUnifiedAddressToPasteboard() throws {
        let testPasteboard = PasteboardClient.testPasteboard
        let uAddress = try UnifiedAddress(encoding: uAddressEncoding, network: .testnet)

        let store = TestStore(
            initialState: AddressDetailsReducer.State(uAddress: uAddress),
            reducer: AddressDetailsReducer()
        ) {
            $0.pasteboard = testPasteboard
        }

        store.send(.copyUnifiedAddressToPastboard)
        
        XCTAssertEqual(
            testPasteboard.getString(),
            uAddress.stringEncoded,
            "AddressDetails: `testCopyUnifiedAddressToPasteboard` is expected to match the input `\(uAddress.stringEncoded)`"
        )
    }
}
