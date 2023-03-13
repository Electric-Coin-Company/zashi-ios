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
        let store = Store(
            initialState: .placeholder,
            reducer: SettingsReducer()
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.sdkSynchronizer, NoopSDKSynchronizer())
                .dependency(\.walletStorage, .noOp)
                .dependency(\.appVersion, .mock)
        )
        
        addAttachments(SettingsView(store: store))
    }
    
    func testAboutSnapshot() throws {
        let store = Store(
            initialState: .placeholder,
            reducer: SettingsReducer()
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.sdkSynchronizer, NoopSDKSynchronizer())
                .dependency(\.walletStorage, .noOp)
                .dependency(\.appVersion, .liveValue)
        )
        
        ViewStore(store).send(.onAppear)
        addAttachments(About(store: store))
    }
}
