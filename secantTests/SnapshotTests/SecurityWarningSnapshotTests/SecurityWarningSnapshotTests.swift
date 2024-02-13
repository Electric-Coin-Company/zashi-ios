//
//  SecurityWarningSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 05.10.2023.
//

import XCTest
import ComposableArchitecture
import SecurityWarning
import ZcashLightClientKit
@testable import secant_testnet

class SecurityWarningSnapshotTests: XCTestCase {
    func testSecurityWarningSnapshot() throws {
        let store = Store(
            initialState: .initial
        ) {
            SecurityWarningReducer(network: ZcashNetworkBuilder.network(for: .mainnet))
                .dependency(\.appVersion, .mock)
        }

        addAttachments(SecurityWarningView(store: store))
        
        ViewStore(store, observe: { $0 }).send(.binding(.set(\.$isAcknowledged, true)))

        addAttachments(SecurityWarningView(store: store))
    }
}
