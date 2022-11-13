//
//  RecoveryPhraseRandomizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.06.2022.
//

import Foundation

struct RecoveryPhraseRandomizer {
    func random(phrase: RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State {
        let missingIndices = randomIndices()
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices).shuffled()
        
        return RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
    
    func randomIndices() -> [Int] {
        (0..<RecoveryPhraseValidationFlowReducer.State.phraseChunks).map { _ in
            Int.random(in: 0 ..< RecoveryPhraseValidationFlowReducer.State.wordGroupSize)
        }
    }
}
