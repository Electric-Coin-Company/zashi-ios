//
//  RecoveryPhraseDisplaySnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
import ComposableArchitecture
import RecoveryPhraseDisplay
@testable import secant_testnet

class RecoveryPhraseDisplaySnapshotTests: XCTestCase {
    func testRecoveryPhraseDisplaySnapshot() throws {
        let store = RecoveryPhraseDisplayStore(
            initialState: .init(phrase: .placeholder),
            reducer: RecoveryPhraseDisplayReducer.demo,
            environment: Void()
        )
        
        addAttachments(RecoveryPhraseDisplayView(store: store))
    }
}
