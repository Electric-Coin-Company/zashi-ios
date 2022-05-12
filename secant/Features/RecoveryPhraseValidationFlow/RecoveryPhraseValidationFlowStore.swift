//
//  RecoveryPhraseValidation.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias RecoveryPhraseValidationFlowReducer = Reducer<
    RecoveryPhraseValidationFlowState,
    RecoveryPhraseValidationFlowAction,
    RecoveryPhraseValidationFlowEnvironment
>
typealias RecoveryPhraseValidationFlowStore = Store<RecoveryPhraseValidationFlowState, RecoveryPhraseValidationFlowAction>
typealias RecoveryPhraseValidationFlowViewStore = ViewStore<RecoveryPhraseValidationFlowState, RecoveryPhraseValidationFlowAction>

// MARK: - State

struct RecoveryPhraseValidationFlowState: Equatable {
    enum Route: Equatable, CaseIterable {
        case validation
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

extension RecoveryPhraseValidationFlowState {
    /// creates an initial `RecoveryPhraseValidationState` with no completions and random missing indices.
    /// - Note: Use this function to create a random validation puzzle for a given phrase.
    static func random(phrase: RecoveryPhrase) -> Self {
        let missingIndices = Self.randomIndices()
        let missingWordChipKind = phrase.words(fromMissingIndices: missingIndices).shuffled()

        return RecoveryPhraseValidationFlowState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChipKind,
            validationWords: []
        )
    }
}

extension RecoveryPhraseValidationFlowState {
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

// MARK: - Action

enum RecoveryPhraseValidationFlowAction: Equatable {
    case updateRoute(RecoveryPhraseValidationFlowState.Route?)
    case reset
    case move(wordChip: PhraseChip.Kind, intoGroup: Int)
    case succeed
    case fail
    case failureFeedback
    case proceedToHome
    case displayBackedUpPhrase
}

// MARK: - Environment

struct RecoveryPhraseValidationFlowEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let newPhrase: () -> Effect<RecoveryPhrase, RecoveryPhraseError>
    let pasteboard: WrappedPasteboard
    let feedbackGenerator: WrappedFeedbackGenerator
}

extension RecoveryPhraseValidationFlowEnvironment {
    private struct DemoPasteboard {
        static var general = Self()
        var string: String?
    }

    static let demo = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { Effect(value: .init(words: RecoveryPhrase.placeholder.words)) },
        pasteboard: .test,
        feedbackGenerator: .silent
    )
        
    static let live = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { Effect(value: .init(words: RecoveryPhrase.placeholder.words)) },
        pasteboard: .live,
        feedbackGenerator: .haptic
    )
}

// MARK: - Reducer

extension RecoveryPhraseValidationFlowReducer {
    static let `default` = RecoveryPhraseValidationFlowReducer { state, action, environment in
        switch action {
        case .reset:
            state = RecoveryPhraseValidationFlowState.random(phrase: state.phrase)
            state.route = .validation
            // FIXME: Resetting causes route to be nil = preamble screen, hence setting the .validation. The transition back is not animated though (issue 186)

        case let .move(wordChip, group):
            guard
                case let PhraseChip.Kind.unassigned(word, color) = wordChip,
                let missingChipIndex = state.missingWordChips.firstIndex(of: wordChip)
            else { return .none }

            state.missingWordChips[missingChipIndex] = .empty
            state.validationWords.append(ValidationWord(groupIndex: group, word: word))

            if state.isComplete {
                let value: RecoveryPhraseValidationFlowAction = state.isValid ? .succeed : .fail
                let effect = Effect<RecoveryPhraseValidationFlowAction, Never>(value: value)
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
            guard let route = route else {
                state = RecoveryPhraseValidationFlowState.random(phrase: state.phrase)
                return .none
            }
            state.route = route

        case .proceedToHome:
            break

        case .displayBackedUpPhrase:
            break
        }
        return .none
    }
}

// MARK: - ViewStore

extension RecoveryPhraseValidationFlowViewStore {
    func bindingForRoute(_ route: RecoveryPhraseValidationFlowState.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

extension RecoveryPhraseValidationFlowViewStore {
    var bindingForValidation: Binding<Bool> {
        self.binding(
            get: { $0.route != nil },
            send: { isActive in
                return .updateRoute(isActive ? .validation : nil)
            }
        )
    }

    var bindingForSuccess: Binding<Bool> {
        self.binding(
            get: { $0.route == .success },
            send: { isActive in
                return .updateRoute(isActive ? .success : .validation)
            }
        )
    }

    var bindingForFailure: Binding<Bool> {
        self.binding(
            get: { $0.route == .failure },
            send: { isActive in
                return .updateRoute(isActive ? .failure : .validation)
            }
        )
    }
}

// MARK: - Placeholders

extension RecoveryPhraseValidationFlowState {
    static let placeholder = RecoveryPhraseValidationFlowState.random(phrase: .placeholder)

    static let placeholderStep1 = RecoveryPhraseValidationFlowState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .unassigned(word: "thank"),
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning")
        ],
        route: nil
    )

    static let placeholderStep2 = RecoveryPhraseValidationFlowState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank")
        ],
        route: nil
    )

    static let placeholderStep3 = RecoveryPhraseValidationFlowState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .empty
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank"),
            .init(groupIndex: 3, word: "garlic")
        ],
        route: nil
    )

    static let placeholderStep4 = RecoveryPhraseValidationFlowState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .empty,
            .empty
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank"),
            .init(groupIndex: 3, word: "garlic"),
            .init(groupIndex: 1, word: "boil")
        ],
        route: nil
    )
}

extension RecoveryPhraseValidationFlowStore {
    private static let scheduler = DispatchQueue.main

    static let demo = Store(
        initialState: .placeholder,
        reducer: .default,
        environment: .demo
    )

    static let demoStep1 = Store(
        initialState: .placeholderStep1,
        reducer: .default,
        environment: .demo
    )

    static let demoStep2 = Store(
        initialState: .placeholderStep1,
        reducer: .default,
        environment: .demo
    )

    static let demoStep3 = Store(
        initialState: .placeholderStep3,
        reducer: .default,
        environment: .demo
    )

    static let demoStep4 = Store(
        initialState: .placeholderStep4,
        reducer: .default,
        environment: .demo
    )
}
