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

/// Represents the completion of a group of recovery words by de addition of one word into the given group
struct RecoveryPhraseStepCompletion: Equatable {
    var groupIndex: Int
    var word: String
}

struct RecoveryPhraseValidationState: Equatable {
    enum Step: Equatable {
        case initial
        case incomplete
        case complete
    }

    static let wordGroupSize = 6
    static let phraseChunks = 4

    var phrase: RecoveryPhrase
    var missingIndices: [Int]
    var missingWordChips: [PhraseChip.Kind]
    var completion: [RecoveryPhraseStepCompletion]

    var step: Step {
        guard !completion.isEmpty else {
            return  .initial
        }

        guard completion.count >= missingIndices.count else {
            return .incomplete
        }

        return .complete
    }

    var isValid: Bool {
        Self.resultingPhrase(from: completion, missingIndices: missingIndices, originalPhrase: phrase, numberOfGroups: missingIndices.count) == phrase.words
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
    /// Given an array of RecoveryPhraseStepCompletion, missing indices, original phrase and the number of groups it was split into,
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

    /// drives the state machine represented on this Enum by the action of applying a chip into a group of words containing an empty slot that has to be completed
    func apply(chip: PhraseChip.Kind, into group: Int) -> Self {
        guard case let PhraseChip.Kind.unassigned(word) = chip else { return self }

        switch self.step {
        case .initial:
            guard let missingChipIndex = missingWordChips.firstIndex(of: chip) else { return self }

            var newMissingWords = missingWordChips
            newMissingWords[missingChipIndex] = .empty

            return RecoveryPhraseValidationState(
                phrase: phrase,
                missingIndices: missingIndices,
                missingWordChips: newMissingWords,
                completion: [RecoveryPhraseStepCompletion(groupIndex: group, word: word)]
            )

        case .incomplete:
            guard let missingChipIndex = missingWordChips.firstIndex(of: chip) else { return self }

            if completion.count < (RecoveryPhraseValidationState.phraseChunks - 1) {
                var newMissingWords = missingWordChips
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
            return self
        }
    }

    static func pickWordsFromMissingIndices(indices: [Int], phrase: RecoveryPhrase) -> [PhraseChip.Kind] {
        precondition((indices.count - 1) * Self.wordGroupSize <= phrase.words.count)
        var words: [PhraseChip.Kind] = []
        indices.enumerated().forEach({ index, position in
            let realIndex = (index * Self.wordGroupSize) + position
            words.append(.unassigned(word: phrase.words[realIndex]))
        })
        return words
    }

    static func randomIndices() -> [Int] {
        Array(repeating: Int.random(in: 0...wordGroupSize - 1), count: phraseChunks)
    }
}

extension RecoveryPhrase.Chunk {
    /// Returns an array of words where the word at the missing index will be an empty string
    func words(with missingIndex: Int) -> [String] {
        precondition(missingIndex >= 0)
        precondition(missingIndex < self.words.count)
        var wordsApplyingMissing = self.words
        wordsApplyingMissing[missingIndex] = ""
        return wordsApplyingMissing
    }
}

enum RecoveryPhraseValidationAction: Equatable {
    case reset
    case drag(wordChip: PhraseChip.Kind, intoGroup: Int)
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
            state = state.apply(chip: wordChip, into: group)
            return .none

        case .succeed:
            return .none

        case .fail:
            state = RecoveryPhraseValidationState.random(phrase: state.phrase)
            return .none
        }
    }
}
