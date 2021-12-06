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
    /**
     Represents the completion of a group of recovery words by de addition of one word into the given group
     */
    struct StepCompletion: Equatable {
        var groupIndex: Int
        var word: String
    }

    enum ValidationStep: Equatable {
        case initial(phrase: RecoveryPhrase, missingIndices: [Int], missingWordsChips: [PhraseChip.Kind])
        case incomplete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [StepCompletion], missingWordsChips: [PhraseChip.Kind])
        case complete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [StepCompletion], missingWordsChips: [PhraseChip.Kind])
        case valid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [StepCompletion], missingWordsChips: [PhraseChip.Kind])
        case invalid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [StepCompletion], missingWordsChips: [PhraseChip.Kind])

        /**
         drives the state machine represented on this Enum by the action of applying a chip into a group of words containing an empty slot that has to be completed
         */
        static func given(step: ValidationStep, apply chip: PhraseChip.Kind, into group: Int) -> ValidationStep {
            guard case let PhraseChip.Kind.unassigned(word) = chip else { return step }

            switch step {
            case let .initial(phrase, missingIndices, missingWordsChips):
                guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return step }

                var newMissingWords = missingWordsChips
                newMissingWords[missingChipIndex] = .empty

                return .incomplete(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: [StepCompletion(groupIndex: group, word: word)],
                    missingWordsChips: newMissingWords
                )

            case let .incomplete(phrase, missingIndices, completion, missingWordsChips):
                guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return step }

                if completion.count < (RecoveryPhraseValidationState.phraseChunks - 1) {
                    var newMissingWords = missingWordsChips
                    newMissingWords[missingChipIndex] = .empty

                    var newCompletionState = Array(completion)
                    newCompletionState.append(StepCompletion(groupIndex: group, word: word))

                    return .incomplete(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: newCompletionState,
                        missingWordsChips: newMissingWords
                    )
                } else {
                    var newCompletion = completion
                    newCompletion.append(StepCompletion(groupIndex: group, word: word))
                    
                    return .complete(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: newCompletion,
                        missingWordsChips: missingWordsChips
                    )
                }
            default:
                return step
            }
        }

        static func resultingPhrase(
            from completion: [StepCompletion],
            missingIndices: [Int],
            originalPhrase: RecoveryPhrase,
            numberOfGroups: Int
        ) -> [String] {
            precondition(missingIndices.count == completion.count)
            precondition(completion.count == numberOfGroups)

            var words = originalPhrase.words
            let groupLength = words.count / numberOfGroups
            // iterate based on the completions the user did on the UI
            for wordCompletion in completion {
                // figure out which phrase group (chunk) this completion belongs to
                let i = wordCompletion.groupIndex
                // validate that's the right number
                precondition(i < numberOfGroups)
                // get the missing index that the user did this completion for on the given group
                let missingIndex = missingIndices[i]
                // figure out what this means in terms of the whole recovery phrase
                let concreteIndex = i * groupLength + missingIndex
                precondition(concreteIndex < words.count)
                // replace the word on the copy of the original phrase with the completion the user did
                words[concreteIndex] = wordCompletion.word
            }

            return words
        }
        /**
         validates that the resulting word on the complete state matches the original word and moves the state into either valid or invalid
         */
        mutating func validate() {
            switch self {
            case let .complete(phrase, missingIndices, completion, missingWordsChips):
                let resultingPhrase = Self.resultingPhrase(from: completion, missingIndices: missingIndices, originalPhrase: phrase, numberOfGroups: RecoveryPhraseValidationState.phraseChunks)
                if resultingPhrase == phrase.words {
                    self = .valid(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: completion,
                        missingWordsChips: missingWordsChips
                    )
                } else {
                    self = .invalid(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: completion,
                        missingWordsChips: missingWordsChips
                    )
                }
            default:
                break
            }
        }
    }

    static let wordGroupSize = 6
    static let phraseChunks = 4

    var step: ValidationStep

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

    static func firstStep(phrase: RecoveryPhrase) -> ValidationStep {
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
        self.step = ValidationStep.given(step: self.step, apply: chip, into: group)
    }
}

enum RecoveryPhraseValidationAction: Equatable {
    case reset
    case drag(wordChip: PhraseChip.Kind, intoGroup: Int)
    case validate
    case succeed
    case fail
}

let validatePhraseFlowReducer = Reducer<RecoveryPhraseValidationState, RecoveryPhraseValidationAction, RecoveryPhraseEnvironment> { state, action, _ in
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
