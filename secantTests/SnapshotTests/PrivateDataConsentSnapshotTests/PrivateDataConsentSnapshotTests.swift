//
//  PrivateDataConsentSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 01.11.2023.
//

import XCTest
import ComposableArchitecture
import PrivateDataConsent
@testable import secant_testnet

class PrivateDataConsentSnapshotTests: XCTestCase {
    func testPrivateDataConsentSnapshot() throws {
        let store = Store(
            initialState: .placeholder,
            reducer: PrivateDataConsentReducer(networkType: .mainnet)
                .dependency(\.databaseFiles, .noOp)
        )

        addAttachments(PrivateDataConsentView(store: store))
        
        ViewStore(store).send(.binding(.set(\.isAcknowledged, true)))

        addAttachments(PrivateDataConsentView(store: store))
    }
}
