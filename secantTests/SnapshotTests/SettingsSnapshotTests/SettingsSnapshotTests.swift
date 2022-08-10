//
//  SettingsSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import SwiftUI

class SettingsSnapshotTests: XCTestCase {
    func testSettingsSnapshot() throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = Store(
            initialState: .placeholder,
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        addAttachments(SettingsView(store: store))
    }
}
