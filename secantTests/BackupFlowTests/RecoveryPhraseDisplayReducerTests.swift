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
            initialState: .test,
            reducer: .default,
            environment: .demo
        )
                
        store.send(.copyToBufferPressed) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = true
        }

        XCTAssertEqual(
            store.environment.pasteboard.getString(),
            RecoveryPhrase.placeholder.toString()
        )
    }
    
    func testNewPhrase() {
        let store = TestStore(
            initialState: .empty,
            reducer: .default,
            environment: .demo
        )
                
        store.send(.phraseResponse(.placeholder)) {
            $0.phrase = .placeholder
            $0.showCopyToBufferAlert = false
        }
    }
}

private extension RecoveryPhraseDisplayState {
    static let test = RecoveryPhraseDisplayState(
        phrase: .placeholder,
        showCopyToBufferAlert: false
    )
    
    static let empty = RecoveryPhraseDisplayState(
        phrase: .empty,
        showCopyToBufferAlert: false
    )
}
