//
//  RecoveryPhraseRandomizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.06.2022.
//

import Foundation
import Models

public struct RecoveryPhraseRandomizer {
    public func random(phrase: RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State {
        let missingIndices = randomIndices()
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices).shuffled()
        
        return RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
    
    public func randomIndices() -> [Int] {
        (0..<RecoveryPhraseValidationFlowReducer.State.phraseChunks).map { _ in
            Int.random(in: 0 ..< RecoveryPhraseValidationFlowReducer.State.wordGroupSize)
        }
    }
}
