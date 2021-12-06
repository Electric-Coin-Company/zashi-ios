//
//  RecoveryPhraseValidation.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import Foundation
import ComposableArchitecture

struct RecoveryPhraseEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var newPhrase: () -> Effect<RecoveryPhrase, AppError>
}

struct RecoveryPhraseValidationState: Equatable {
    static let wordGroupSize = 6
    static let phraseChunks = 4

    var step: RecoveryPhraseValidationStep

    static func pickWordsFromMissingIndices(indices: [Int], phrase: RecoveryPhrase) -> [PhraseChip.Kind] {
        precondition((indices.count - 1) * wordGroupSize <= phrase.words.count)
        var words: [PhraseChip.Kind] = []
        indices.enumerated().forEach({ index, position in
            let realIndex = (index * wordGroupSize) + position
            words.append(.unassigned(word: phrase.words[realIndex]))
        })
        return words
    }

    static func randomIndices() -> [Int] {
        Array(repeating: Int.random(in: 0...wordGroupSize - 1), count: phraseChunks)
    }

    static func firstStep(phrase: RecoveryPhrase) -> RecoveryPhraseValidationStep {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase).shuffled()
        return .initial(phrase: phrase, missingIndices: missingIndices, missingWordsChips: missingWordChipKind)
    }

    init(phrase: RecoveryPhrase) {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase).shuffled()
        self.step = .initial(phrase: phrase, missingIndices: missingIndices, missingWordsChips: missingWordChipKind)
    }
    /**
    reset the state to the initial step
    */
    mutating func reset() {
        switch self.step {
        case let .initial(phrase, _, _):
            self.step = Self.firstStep(phrase: phrase)

        case .incomplete(let phrase, _, _, _):
            self.step = Self.firstStep(phrase: phrase)

        case .complete(let phrase, _, _, _):
            self.step = Self.firstStep(phrase: phrase)

        case .valid(let phrase, _, _, _):
            self.step = Self.firstStep(phrase: phrase)
            
        case .invalid(let phrase, _, _, _):
            self.step = Self.firstStep(phrase: phrase)
        }
    }
    /**
    call this when the user drops an unassigned word chip into a group/
    */
    mutating func apply(chip: PhraseChip.Kind, into group: Int) {
        self.step = RecoveryPhraseValidationStep.given(step: self.step, apply: chip, into: group)
    }
}

enum RecoveryPhraseValidationAction: Equatable {
    case reset
    case drag(wordChip: PhraseChip.Kind, intoGroup: Int)
    case validate
    case succeed
    case fail
}

let validatePhraseFlowReducer = Reducer<
    RecoveryPhraseValidationState,
    RecoveryPhraseValidationAction,
    RecoveryPhraseEnvironment
    > { state, action, _ in
    switch action {
    case .reset:
        state.reset()
        return .none

    case let .drag(wordChip, intoGroup):
        state.apply(chip: wordChip, into: intoGroup)
        return .none

    case .validate:
        state.step.validate()
        return .none

    case .succeed:
        return .none
    case .fail:
        state.reset()
        return .none
    }
}
