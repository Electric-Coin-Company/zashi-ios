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
    enum Step: Equatable {
        case initial(phrase: RecoveryPhrase, missingIndices: [Int], missingWordsChips: [PhraseChip.Kind])
        case incomplete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
        case complete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
        case valid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
        case invalid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])



        /// Given an an array of RecoveryPhraseStepCompletion, missing indices, original phrase and the number of groups it was split into,
        /// assembly the resulting phrase. This comes up with the "proposed solution" for the recovery phrase validation challenge.
        /// - returns:an array of String containing the recovery phrase words ordered by the original phrase order.
        static func resultingPhrase(
            from completion: [RecoveryPhraseStepCompletion],
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

        /// validates that the resulting word on the complete state matches the original word and moves the state into either valid or invalid
        static func validateAndProceed(_ step: RecoveryPhraseValidationState.Step) -> RecoveryPhraseValidationState.Step {
            switch step {
            case let .complete(phrase, missingIndices, completion, missingWordsChips):
                let resultingPhrase = Self.resultingPhrase(
                    from: completion,
                    missingIndices: missingIndices,
                    originalPhrase: phrase,
                    numberOfGroups: RecoveryPhraseValidationState.phraseChunks
                )

                if resultingPhrase == phrase.words {
                    return .valid(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: completion,
                        missingWordsChips: missingWordsChips
                    )
                } else {
                    return .invalid(
                        phrase: phrase,
                        missingIndices: missingIndices,
                        completion: completion,
                        missingWordsChips: missingWordsChips
                    )
                }
            case let .incomplete(phrase, missingIndices, completion, missingWordsChips):
                return .invalid(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: completion,
                    missingWordsChips: missingWordsChips
                )
            case .initial(phrase: let phrase, missingIndices: let missingIndices, missingWordsChips: let missingWordsChips):
                return .invalid(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: [],
                    missingWordsChips: missingWordsChips
                )
            case .valid, .invalid:
                return step
            }
        }
    }

    static let wordGroupSize = 6
    static let phraseChunks = 4

    var phrase: RecoveryPhrase
    var missingIndices: [Int]
    var missingWordChips: [PhraseChip.Kind]
    var completion: [RecoveryPhraseStepCompletion]

    var step: Step {
        guard !completion.isEmpty else {
            return  .initial(phrase: phrase, missingIndices: missingIndices, missingWordsChips: missingWordChips)
        }

        guard completion.count >= missingIndices.count else {
            return .incomplete(phrase: phrase, missingIndices: missingIndices, completion: completion, missingWordsChips: missingWordChips)
        }

        return .complete(phrase: phrase, missingIndices: missingIndices, completion: completion, missingWordsChips: missingWordChips)
    }

    var isValid: Bool {
        Step.resultingPhrase(from: completion, missingIndices: missingIndices, originalPhrase: phrase, numberOfGroups: missingIndices.count) == phrase.words
    }
}

extension RecoveryPhraseValidationState {
    /// creates an initial `RecoveryPhraseValidationState` with no completions and random missing indices.
    /// - Note: Use this function to create a random validation puzzle for a given phrase.
    static func random(phrase: RecoveryPhrase) -> Self {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase).shuffled()
        return RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            completion: []
        )
    }
}

extension RecoveryPhraseValidationState {


    /// drives the state machine represented on this Enum by the action of applying a chip into a group of words containing an empty slot that has to be completed
    static func given(_ state: RecoveryPhraseValidationState, apply chip: PhraseChip.Kind, into group: Int) -> Self {
        guard case let PhraseChip.Kind.unassigned(word) = chip else { return state }

        switch state.step {
        case let .initial(phrase, missingIndices, missingWordsChips):
            guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return state }

            var newMissingWords = missingWordsChips
            newMissingWords[missingChipIndex] = .empty

            return RecoveryPhraseValidationState(
                phrase: phrase,
                missingIndices: missingIndices,
                missingWordChips: newMissingWords,
                completion: [RecoveryPhraseStepCompletion(groupIndex: group, word: word)]
            )

        case let .incomplete(phrase, missingIndices, completion, missingWordsChips):
            guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return state }

            if completion.count < (RecoveryPhraseValidationState.phraseChunks - 1) {
                var newMissingWords = missingWordsChips
                newMissingWords[missingChipIndex] = .empty

                var newCompletionState = Array(completion)
                newCompletionState.append(RecoveryPhraseStepCompletion(groupIndex: group, word: word))

                return RecoveryPhraseValidationState(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    missingWordChips: newMissingWords,
                    completion: newCompletionState
                )
            } else {
                var newCompletion = completion
                newCompletion.append(RecoveryPhraseStepCompletion(groupIndex: group, word: word))

                return RecoveryPhraseValidationState(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    missingWordChips: Array(repeating: .empty, count: RecoveryPhraseValidationState.phraseChunks),
                    completion: newCompletion
                )
            }
        default:
            return state
        }
    }

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

    static func firstStep(phrase: RecoveryPhrase) -> Step {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase).shuffled()
        return .initial(phrase: phrase, missingIndices: missingIndices, missingWordsChips: missingWordChipKind)
    }

    /// reset the state to the initial step
    static func reset(_ step: Step) -> Step {
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

typealias RecoveryPhraseValidationReducer = Reducer<RecoveryPhraseValidationState, RecoveryPhraseValidationAction, Void>

extension RecoveryPhraseValidationReducer {
    static let `default` = RecoveryPhraseValidationReducer { state, action, _ in
        switch action {
        case .reset:
            state = RecoveryPhraseValidationState.random(phrase: state.phrase)
            return .none

        case let .drag(wordChip, group):
            state = .given(state, apply: wordChip, into: group)
            return .none

        case .validate:
//            state.step = .validateAndProceed(state.step)
            return .none

        case .succeed:
            return .none

        case .fail:
            state = RecoveryPhraseValidationState.random(phrase: state.phrase)
            return .none
        }
    }
}
