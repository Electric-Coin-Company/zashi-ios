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
    func testSynchronizerStateChanged_AnyButSynced() throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: ProfileReducer()
                .dependency(\.sdkSynchronizer, TestWrappedSDKSynchronizer())
        )
        
        store.dependencies.appVersion = .mock

        store.send(.onAppear) { state in
            state.address = "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8"
            state.appVersion = "0.0.1"
            state.appBuild = "31"
            state.sdkVersion = "0.16.5-beta"
        }
    }
}
