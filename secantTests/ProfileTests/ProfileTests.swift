//
//  ProfileTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class ProfileTests: XCTestCase {
    @MainActor func testSynchronizerStateChanged_AnyButSynced() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ProfileReducer()
        )

        store.dependencies.appVersion = .mock
        store.dependencies.sdkSynchronizer = SDKSynchronizerDependency.mock

        _ = await store.send(.onAppear)

        await store.receive(.onAppearFinished("ztestsapling1edm52k336nk70gxqxedd89slrrf5xwnnp5rt6gqnk0tgw4mynv6fcx42ym6x27yac5amvfvwypz")) { state in
            state.address = "ztestsapling1edm52k336nk70gxqxedd89slrrf5xwnnp5rt6gqnk0tgw4mynv6fcx42ym6x27yac5amvfvwypz"
            state.appVersion = "0.0.1"
            state.appBuild = "31"
            state.sdkVersion = "0.17.0-beta"
        }

        await store.finish(timeout: NSEC_PER_SEC * 5)
    }
}
