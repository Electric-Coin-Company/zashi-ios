//
//  RecoveryPhraseValidation.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import Foundation
import ComposableArchitecture

typealias RecoveryPhraseValidationStore = Store<RecoveryPhraseValidationState, RecoveryPhraseValidationAction>
typealias RecoveryPhraseValidationViewStore = ViewStore<RecoveryPhraseValidationState, RecoveryPhraseValidationAction>

struct RecoveryPhraseEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var newPhrase: () -> Effect<RecoveryPhrase, AppError>
}

struct RecoveryPhraseValidationState: Equatable {
    static let wordGroupSize = 6
    static let phraseChunks = 4

    var step: RecoveryPhraseValidationStep

    init(phrase: RecoveryPhrase) {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase).shuffled()
        self.step = .initial(phrase: phrase, missingIndices: missingIndices, missingWordsChips: missingWordChipKind)
    }
}

extension RecoveryPhraseValidationState {
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

    /// reset the state to the initial step
    static func reset(_ step: RecoveryPhraseValidationStep) -> RecoveryPhraseValidationStep {
        switch step {
        case let .initial(phrase, _, _):
            return Self.firstStep(phrase: phrase)

        case .incomplete(let phrase, _, _, _):
            return Self.firstStep(phrase: phrase)

        case .complete(let phrase, _, _, _):
            return Self.firstStep(phrase: phrase)

        case .valid(let phrase, _, _, _):
            return Self.firstStep(phrase: phrase)

        case .invalid(let phrase, _, _, _):
            return Self.firstStep(phrase: phrase)
        }
    }
}

enum RecoveryPhraseValidationAction: Equatable {
    case reset
    case drag(wordChip: PhraseChip.Kind, intoGroup: Int)
    case validate
    case succeed
    case fail
}

typealias RecoveryPhraseValidationReducer = Reducer<RecoveryPhraseValidationState, RecoveryPhraseValidationAction, RecoveryPhraseValidationEnvironment>

struct RecoveryPhraseValidationEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validateStep: (RecoveryPhraseValidationStep) -> Effect<RecoveryPhraseValidationStep, Error>
}

extension RecoveryPhraseValidationReducer {
    static let `default` = RecoveryPhraseValidationReducer { state, action, environment in
        switch action {
        case .reset:
            state.step = RecoveryPhraseValidationState.reset(state.step)
            return .none

        case let .drag(wordChip, group):
            state.step = .given(step: state.step, apply: wordChip, into: group)
            return .none

        case .validate:
            state.step = .validateAndProceed(state.step)
            return .none

        case .succeed:
            return .none

        case .fail:
            state.step = RecoveryPhraseValidationState.reset(state.step)
            return .none
        }
    }
}
