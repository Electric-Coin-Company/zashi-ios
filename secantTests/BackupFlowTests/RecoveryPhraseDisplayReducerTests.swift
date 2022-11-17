//
//  RecoveryPhraseDisplayStoreTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 12/8/21.
//

import XCTest
import ComposableArchitecture
@testable import secant_testnet

class RecoveryPhraseDisplayReducerTests: XCTestCase {
    func testCopyToBuffer() {
        let testPasteboard = PasteboardClient.testPasteboard

        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.test,
            reducer: RecoveryPhraseDisplayReducer()
        ) {
            $0.pasteboard = testPasteboard
        }

        store.send(.copyToBufferPressed) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = true
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
                
        store.send(.phraseResponse(.placeholder)) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = false
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
