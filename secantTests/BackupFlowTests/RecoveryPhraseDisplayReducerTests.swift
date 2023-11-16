//
//  RecoveryPhraseDisplayStoreTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 12/8/21.
//

import XCTest
import ComposableArchitecture
import Pasteboard
import Models
import RecoveryPhraseDisplay
@testable import secant_testnet

class RecoveryPhraseDisplayReducerTests: XCTestCase {
    @MainActor func testCopyToBuffer() async {
        let testPasteboard = PasteboardClient.testPasteboard

        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.test
        ) {
            RecoveryPhraseDisplayReducer()
        }

        store.dependencies.pasteboard = testPasteboard

        await store.send(.copyToBufferPressed) { state in
            state.phrase = .placeholder
            state.showCopyToBufferAlert = true
        }

        XCTAssertEqual(
            testPasteboard.getString(),
            RecoveryPhrase.placeholder.toString()
        )
        
        await store.finish()
    }
}

private extension RecoveryPhraseDisplayStore {
    static let test = RecoveryPhraseDisplayReducer.State(
        phrase: .placeholder,
        showCopyToBufferAlert: false
    )
    
    static let empty = RecoveryPhraseDisplayReducer.State(
        phrase: .initial,
        showCopyToBufferAlert: false
    )
}
