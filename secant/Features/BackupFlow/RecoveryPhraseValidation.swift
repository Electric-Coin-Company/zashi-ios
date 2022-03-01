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

/// Represents the data of a word that has been placed into an empty position, that will be used
/// to validate the completed phrase when all ValidationWords have been placed.
struct ValidationWord: Equatable {
    var groupIndex: Int
    var word: String
}

struct RecoveryPhraseValidationState: Equatable {
    enum Route: Equatable, CaseIterable {
        case recoveryBackupPhraseValidation
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
    
    var isComplete: Bool {
        !validationWords.isEmpty && validationWords.count == missingIndices.count
    }

    var isValid: Bool {
        guard let resultingPhrase = self.resultingPhrase else { return false }
        return resultingPhrase == phrase.words
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
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices)

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
    /// - returns:an array of String containing the recovery phrase words ordered by the original phrase order, or `nil`
    /// if a resulting phrase can't be formed because the validation state is not complete.
    var resultingPhrase: [String]? {
        guard missingIndices.count == validationWords.count else { return nil }

        guard validationWords.count == Self.phraseChunks else { return nil }

        var words = phrase.words
        let groupLength = words.count / Self.phraseChunks
        // iterate based on the completions the user did on the UI
        for validationWord in validationWords {
            // figure out which phrase group (chunk) this completion belongs to
            let groupIndex = validationWord.groupIndex

            // validate that's the right number
            assert(groupIndex < Self.phraseChunks)

            // get the missing index that the user did this completion for on the given group
            let missingIndex = missingIndices[groupIndex]

            // figure out what this means in terms of the whole recovery phrase
            let concreteIndex = groupIndex * groupLength + missingIndex

            assert(concreteIndex < words.count)

            // replace the word on the copy of the original phrase with the completion the user did
            words[concreteIndex] = validationWord.word
        }

        return words
    }

    static func randomIndices() -> [Int] {
        return (0..<phraseChunks).map { _ in
            Int.random(in: 0 ..< wordGroupSize)
        }
    }
}

extension RecoveryPhrase.Group {
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
    case recoveryBackupPhraseValidation
    case updateRoute(RecoveryPhraseValidationState.Route?)
    case reset
    case move(wordChip: PhraseChip.Kind, intoGroup: Int)
    case succeed
    case fail
    case failureFeedback
    case proceedToHome
    case displayBackedUpPhrase
}

typealias RecoveryPhraseValidationReducer = Reducer<RecoveryPhraseValidationState, RecoveryPhraseValidationAction, BackupPhraseEnvironment>

extension RecoveryPhraseValidationReducer {
    static let `default` = RecoveryPhraseValidationReducer { state, action, environment in
        switch action {
        case .reset:
            state = RecoveryPhraseValidationState.random(phrase: state.phrase)

        case let .move(wordChip, group):
            guard
                case let PhraseChip.Kind.unassigned(word, color) = wordChip,
                let missingChipIndex = state.missingWordChips.firstIndex(of: wordChip)
            else { return .none }

            state.missingWordChips[missingChipIndex] = .empty
            state.validationWords.append(ValidationWord(groupIndex: group, word: word))

            if state.isComplete {
                let value: RecoveryPhraseValidationAction = state.isValid ? .succeed : .fail
                let effect = Effect<RecoveryPhraseValidationAction, Never>(value: value)
                    .delay(for: 1, scheduler: environment.mainQueue)
                    .eraseToEffect()
                
                if value == .succeed {
                    return effect
                } else {
                    return .concatenate(
                        Effect(value: .failureFeedback),
                        effect
                    )
                }
            }
            return .none

        case .succeed:
            state.route = .success

        case .fail:
            state.route = .failure

        case .failureFeedback:
            environment.feedbackGenerator.generateFeedback()

        case .updateRoute(let route):
            state.route = route

        case .proceedToHome:
            break

        case .displayBackedUpPhrase:
            break
            
        case .recoveryBackupPhraseValidation:
            state.route = .recoveryBackupPhraseValidation
        }
        return .none
    }
}
