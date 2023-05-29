//
//  RecoveryPhraseDisplayStoreTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 12/8/21.
//

import XCTest
import ComposableArchitecture
import PasteboardClient
@testable import secant_testnet

class RecoveryPhraseDisplayReducerTests: XCTestCase {
    func testCopyToBuffer() {
        let testPasteboard = PasteboardClient.testPasteboard

        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.test,
            reducer: RecoveryPhraseDisplayReducer()
        )

        store.dependencies.pasteboard = testPasteboard

        store.send(.copyToBufferPressed) { state in
            state.phrase = .placeholder
            state.showCopyToBufferAlert = true
        }

        XCTAssertEqual(
            testPasteboard.getString(),
            RecoveryPhrase.placeholder.toString()
        )
    }
    
    func testNewPhrase() {
        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.empty,
            reducer: RecoveryPhraseDisplayReducer()
        )
                
        store.send(.phraseResponse(.placeholder)) { state in
            state.phrase = .placeholder
            state.showCopyToBufferAlert = false
        }
    }
}

private extension RecoveryPhraseDisplayStore {
    static let test = RecoveryPhraseDisplayReducer.State(
        phrase: .placeholder,
        showCopyToBufferAlert: false
    )
    
    static let empty = RecoveryPhraseDisplayReducer.State(
        phrase: .empty,
        showCopyToBufferAlert: false
    )
}
