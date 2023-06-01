//
//  WelcomeSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.06.2022.
//

import XCTest
import ComposableArchitecture
import Welcome
@testable import secant_testnet

class WelcomeSnapshotTests: XCTestCase {
    func testWelcomeSnapshot() throws {
        let store = Store(
            initialState: .placeholder,
            reducer: WelcomeReducer()
        )

        addAttachments(WelcomeView(store: store))
    }
}
