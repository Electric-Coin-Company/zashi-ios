//
//  RecoveryPhraseRandomizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.06.2022.
//

import Foundation
import ComposableArchitecture

struct RecoveryPhraseRandomizer {
    func random(phrase: RecoveryPhrase) -> RecoveryPhraseValidationFlow.State {
        let missingIndices = randomIndices()
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices).shuffled()
        
        return RecoveryPhraseValidationFlow.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
    
    func randomIndices() -> [Int] {
        return (0..<RecoveryPhraseValidationFlow.State.phraseChunks).map { _ in
            Int.random(in: 0 ..< RecoveryPhraseValidationFlow.State.wordGroupSize)
        }
    }
}

private enum RecoveryPhraseRandomKey: DependencyKey {
    static let liveValue = WrappedRecoveryPhraseRandomizer.live
}

extension DependencyValues {
    var randomPhrase: WrappedRecoveryPhraseRandomizer {
        get { self[RecoveryPhraseRandomKey.self] }
        set { self[RecoveryPhraseRandomKey.self] = newValue }
    }
}
