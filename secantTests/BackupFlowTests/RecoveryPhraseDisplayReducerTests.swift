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
        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.test,
            reducer: RecoveryPhraseDisplay()
        )
                
        store.send(.copyToBufferPressed) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = true
        }

        XCTAssertEqual(
            store.dependencies.pasteboard.getString(),
            RecoveryPhrase.placeholder.toString()
        )
    }
    
    func testNewPhrase() {
        let store = TestStore(
            initialState: RecoveryPhraseDisplayStore.empty,
            reducer: RecoveryPhraseDisplay()
        )
                
        store.send(.phraseResponse(.placeholder)) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = false
        }
    }
}

private extension RecoveryPhraseDisplayStore {
    static let test = RecoveryPhraseDisplay.State(
        phrase: .placeholder,
        showCopyToBufferAlert: false
    )
    
    static let empty = RecoveryPhraseDisplay.State(
        phrase: .empty,
        showCopyToBufferAlert: false
    )
}
