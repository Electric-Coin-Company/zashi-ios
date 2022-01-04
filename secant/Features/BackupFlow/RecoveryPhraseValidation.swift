//
//  RecoveryPhraseValidation.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias RecoveryPhraseValidationStore = Store<RecoveryPhraseValidationState, RecoveryPhraseValidationAction>
typealias RecoveryPhraseValidationViewStore = ViewStore<RecoveryPhraseValidationState, RecoveryPhraseValidationAction>

/// Represents the completion of a group of recovery words by the addition of one word into the given group
struct ValidationWord: Equatable {
    var groupIndex: Int
    var word: String
}

struct RecoveryPhraseValidationState: Equatable {
    enum Step: Equatable {
        case initial
        case incomplete
        case complete
    }

    enum Route: Equatable, CaseIterable {
        case success
        case failure
    }

    static let wordGroupSize = 6
    static let phraseChunks = 4

    var phrase: RecoveryPhrase
    var missingIndices: [Int]
    var missingWordChips: [PhraseChip.Kind]
    var validationWords: [ValidationWord]
    var route: Route?
    var step: Step {
        guard !validationWords.isEmpty else {
            return  .initial
        }

        guard validationWords.count >= missingIndices.count else {
            return .incomplete
        }

        return .complete
    }

    var isValid: Bool {
        self.resultingPhrase == phrase.words
    }
}

extension RecoveryPhraseValidationViewStore {
    func bindingForRoute(_ route: RecoveryPhraseValidationState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

extension RecoveryPhraseValidationState {
    /// creates an initial `RecoveryPhraseValidationState` with no completions and random missing indices.
    /// - Note: Use this function to create a random validation puzzle for a given phrase.
    static func random(phrase: RecoveryPhrase) -> Self {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = Self.pickWords(fromMissingIndices: missingIndices, phrase: phrase).shuffled()
        return RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
}

extension RecoveryPhraseValidationState {
    /// Given an array of RecoveryPhraseStepCompletion, missing indices, original phrase and the number of groups it was split into,
    /// assembly the resulting phrase. This comes up with the "proposed solution" for the recovery phrase validation challenge.
    /// - returns:an array of String containing the recovery phrase words ordered by the original phrase order.
    var resultingPhrase: [String] {
        assert(missingIndices.count == validationWords.count)
        assert(validationWords.count == Self.phraseChunks)

        var words = phrase.words
        let groupLength = words.count / Self.phraseChunks
        // iterate based on the completions the user did on the UI
        for wordCompletion in validationWords {
            // figure out which phrase group (chunk) this completion belongs to
            let i = wordCompletion.groupIndex
            // validate that's the right number
            assert(i < Self.phraseChunks)
            // get the missing index that the user did this completion for on the given group
            let missingIndex = missingIndices[i]
            // figure out what this means in terms of the whole recovery phrase
            let concreteIndex = i * groupLength + missingIndex
            assert(concreteIndex < words.count)
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
                validationWords: [ValidationWord(groupIndex: group, word: word)]
            )

        case .incomplete:
            guard let missingChipIndex = missingWordChips.firstIndex(of: chip) else { return self }

            if validationWords.count < (RecoveryPhraseValidationState.phraseChunks - 1) {
                var newMissingWords = missingWordChips
                newMissingWords[missingChipIndex] = .empty

                var newCompletionState = Array(validationWords)
                newCompletionState.append(ValidationWord(groupIndex: group, word: word))

                return RecoveryPhraseValidationState(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    missingWordChips: newMissingWords,
                    validationWords: newCompletionState
                )
            } else {
                var newCompletion = validationWords
                newCompletion.append(ValidationWord(groupIndex: group, word: word))

                return RecoveryPhraseValidationState(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    missingWordChips: Array(repeating: .empty, count: RecoveryPhraseValidationState.phraseChunks),
                    validationWords: newCompletion
                )
            }
        case .complete:
            return self
        }
    }

    static func pickWords(fromMissingIndices indices: [Int], phrase: RecoveryPhrase) -> [PhraseChip.Kind] {
        assert((indices.count - 1) * Self.wordGroupSize <= phrase.words.count)

        return indices.enumerated().map({ index, position in
            .unassigned(word: phrase.words[(index * Self.wordGroupSize) + position])
        })
    }

    static func randomIndices() -> [Int] {
        return (0..<phraseChunks).map { _ in
            Int.random(in: 0 ..< wordGroupSize)
        }
    }
}

extension RecoveryPhrase.Chunk {
    /// Returns an array of words where the word at the missing index will be an empty string
    func words(with missingIndex: Int) -> [String] {
        assert(missingIndex >= 0)
        assert(missingIndex < self.words.count)
        var wordsApplyingMissing = self.words
        wordsApplyingMissing[missingIndex] = ""
        return wordsApplyingMissing
    }
}

enum RecoveryPhraseValidationAction: Equatable {
    case updateRoute(RecoveryPhraseValidationState.Route?)
    case reset
    case drag(wordChip: PhraseChip.Kind, intoGroup: Int)
    case succeed
    case fail
    case proceedToHome
    case displayBackedUpPhrase
}

typealias RecoveryPhraseValidationReducer = Reducer<RecoveryPhraseValidationState, RecoveryPhraseValidationAction, BackupPhraseEnvironment>

extension RecoveryPhraseValidationReducer {
    static let `default` = RecoveryPhraseValidationReducer { state, action, environment in
        switch action {
        case .reset:
            state = RecoveryPhraseValidationState.random(phrase: state.phrase)
            return .none

        case let .drag(wordChip, group):
            state = state.apply(chip: wordChip, into: group)

            // Trigger a delayed effect to proceed to the next step
            if case .complete = state.step {
                if state.isValid {
                    return Effect(value: .succeed).delay(for: 1, scheduler: environment.mainQueue).eraseToEffect()
                } else {
                    return Effect(value: .fail).delay(for: 3, scheduler: environment.mainQueue).eraseToEffect()
                }
            }
            return .none

        case .succeed:
            state.route = .success
            return .none

        case .fail:
            state.route = .failure
            return .none

        case .updateRoute(let route):
            state.route = route
            return .none

        case .proceedToHome:
            return .none
            
        case .displayBackedUpPhrase:
            return .none
        }
    }
}
