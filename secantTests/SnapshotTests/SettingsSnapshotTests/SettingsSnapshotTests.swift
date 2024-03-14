//
//  SettingsSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
import ComposableArchitecture
import SwiftUI
import Settings
@testable import secant_testnet

class SettingsSnapshotTests: XCTestCase {
    func testSettingsSnapshot() throws {
        let store = Store(
            initialState: .initial
        ) {
            SettingsReducer()
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.walletStorage, .noOp)
                .dependency(\.appVersion, .mock)
                .dependency(\.restoreWalletStorage, .noOp)
        }
        
        addAttachments(SettingsView(store: store))
    }
    
    func testAboutSnapshot() throws {
        let store = Store(
            initialState: .initial
        ) {
            SettingsReducer()
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.walletStorage, .noOp)
                .dependency(\.appVersion, .liveValue)
                .dependency(\.restoreWalletStorage, .noOp)
        }
        
        ViewStore(store, observe: { $0 }).send(.onAppear)
        
        addAttachments(About(store: store))
    }
}
