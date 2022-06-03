//
//  RecoveryPhraseRandomizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.06.2022.
//

import Foundation

struct RecoveryPhraseRandomizer {
    func random(phrase: RecoveryPhrase) -> RecoveryPhraseValidationFlowState {
        let missingIndices = randomIndices()
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices).shuffled()
        
        return RecoveryPhraseValidationFlowState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
    
    func randomIndices() -> [Int] {
        return (0..<RecoveryPhraseValidationFlowState.phraseChunks).map { _ in
            Int.random(in: 0 ..< RecoveryPhraseValidationFlowState.wordGroupSize)
        }
    }
}
