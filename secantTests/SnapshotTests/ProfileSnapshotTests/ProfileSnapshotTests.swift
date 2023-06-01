//
//  ProfileSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.07.2022.
//

import XCTest
import ComposableArchitecture
import SwiftUI
import Profile
@testable import secant_testnet

class ProfileSnapshotTests: XCTestCase {
    func testProfileSnapshot_sent() throws {
        let store = Store(
            initialState: .placeholder,
            reducer: ProfileReducer()
                .dependency(\.appVersion, .mock)
                .dependency(\.sdkSynchronizer, .noOp)
        )
        
        ViewStore(store).send(.onAppear)
        addAttachments(ProfileView(store: store))
    }
}
