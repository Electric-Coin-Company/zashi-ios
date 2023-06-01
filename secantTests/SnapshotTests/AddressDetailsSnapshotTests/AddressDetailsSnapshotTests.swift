//
//  AddressDetailsSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.01.2023.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import SwiftUI
import AddressDetails
@testable import secant_testnet

class AddressDetailsSnapshotTests: XCTestCase {
    func testAddressDetailsSnapshot() throws {
        // swiftlint:disable line_length
        let uAddress = try UnifiedAddress(
            encoding: "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h",
            network: .testnet
        )

        let store = Store(
            initialState: AddressDetailsReducer.State(uAddress: uAddress),
            reducer: AddressDetailsReducer()
                .dependency(\.walletConfigProvider, .noOp)
        )
        
        addAttachments(AddressDetailsView(store: store))
    }
}
