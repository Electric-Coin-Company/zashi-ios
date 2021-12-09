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
        let environment = BackupPhraseEnvironment.demo
        
        let store = TestStore(
            initialState: RecoveryPhraseDisplayState.test,
            reducer: RecoveryPhraseDisplayReducer.default,
            environment: environment
        )
        
        let phrase = RecoveryPhrase.demo
        
        store.send(.copyToBufferPressed) {
            $0.phrase = phrase
            $0.showCopyToBufferAlert = true
        }
        
        XCTAssertEqual(environment.pasteboard.string, phrase.toString())
    }
    
    func testNewPhrase() {
        let environment = BackupPhraseEnvironment.demo
        
        let store = TestStore(
            initialState: RecoveryPhraseDisplayState.test,
            reducer: RecoveryPhraseDisplayReducer.default,
            environment: environment
        )
        
        let phrase = RecoveryPhrase.demo
        
        store.send(.phraseResponse(.success(phrase))) {
            $0.phrase = phrase
            $0.showCopyToBufferAlert = false
        }
    }
}

private extension RecoveryPhraseDisplayState {
    static let test = RecoveryPhraseDisplayState(phrase: RecoveryPhrase.demo, showCopyToBufferAlert: false)
}
