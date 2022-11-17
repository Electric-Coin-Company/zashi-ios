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
        let store = Store(
            initialState: .placeholder,
            reducer: ProfileReducer()
                .dependency(\.appVersion, .mock)
                .dependency(\.sdkSynchronizer, NoopSDKSynchronizer())
        )
        
        ViewStore(store).send(.onAppear)
        addAttachments(ProfileView(store: store))
    }
}
