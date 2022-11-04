//
//  WelcomeSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class WelcomeSnapshotTests: XCTestCase {
    func testWelcomeSnapshot() throws {
        let store = Store(
            initialState: .placeholder,
            reducer: WelcomeReducer()
        )

        addAttachments(WelcomeView(store: store))
    }
}
