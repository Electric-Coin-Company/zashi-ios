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
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
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
