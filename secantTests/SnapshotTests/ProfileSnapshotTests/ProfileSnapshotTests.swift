//
//  ProfileSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import SwiftUI

class ProfileSnapshotTests: XCTestCase {
    func testProfileSnapshot_sent() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = ProfileEnvironment(
            appVersionHandler: .test,
            mnemonic: .mock,
            shieldedAddress: { "ff3927e1f83df9b1b0dc75540ddc59ee435eecebae914d2e6dfe8576fbedc9a8" },
            scheduler: testScheduler.eraseToAnyScheduler(),
            walletStorage: .throwing,
            zcashSDKEnvironment: .testnet
        )
        
        let store = Store(
            initialState: .placeholder,
            reducer: ProfileReducer.default,
            environment: testEnvironment
        )
        
        ViewStore(store).send(.onAppear)
        addAttachments(ProfileView(store: store))
    }
}
