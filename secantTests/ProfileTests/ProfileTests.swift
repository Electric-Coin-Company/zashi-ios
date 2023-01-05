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
    @MainActor func testSynchronizerStateChanged_AnyButSynced() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ProfileReducer()
        ) { dependencies in
            dependencies.appVersion = .mock
            dependencies.sdkSynchronizer = SDKSynchronizerDependency.mock
        }

        // swiftlint:disable line_length
        let uAddress = try UnifiedAddress(
            encoding: "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h",
            network: .testnet
        )

        _ = await store.send(.onAppear) { state in
            state.addressDetailsState.uAddress = uAddress
            state.appVersion = "0.0.1"
            state.appBuild = "31"
            state.sdkVersion = "0.17.0-beta"
        }
    }
}
