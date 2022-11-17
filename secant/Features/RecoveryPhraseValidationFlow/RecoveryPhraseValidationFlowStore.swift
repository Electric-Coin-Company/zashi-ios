//
//  RecoveryPhraseValidation.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias RecoveryPhraseValidationFlowStore = Store<RecoveryPhraseValidationFlowReducer.State, RecoveryPhraseValidationFlowReducer.Action>
typealias RecoveryPhraseValidationFlowViewStore = ViewStore<RecoveryPhraseValidationFlowReducer.State, RecoveryPhraseValidationFlowReducer.Action>

struct RecoveryPhraseValidationFlowReducer: ReducerProtocol {
    struct State: Equatable {
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

    enum Action: Equatable {
        case updateRoute(RecoveryPhraseValidationFlowReducer.State.Route?)
        case reset
        case move(wordChip: PhraseChip.Kind, intoGroup: Int)
        case succeed
        case fail
        case failureFeedback
        case proceedToHome
        case displayBackedUpPhrase
    }
    
    @Dependency(\.feedbackGenerator) var feedbackGenerator
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.randomRecoveryPhrase) var randomRecoveryPhrase

    // swiftlint:disable:next cyclomatic_complexity
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .reset:
            state = randomRecoveryPhrase.random(state.phrase)
            state.route = .validation
            // FIXME [#186]: Resetting causes route to be nil = preamble screen, hence setting the .validation. The transition back is not animated
            // though

        case let .move(wordChip, group):
            guard
                case let PhraseChip.Kind.unassigned(word, _) = wordChip,
                let missingChipIndex = state.missingWordChips.firstIndex(of: wordChip)
            else { return .none }

            state.missingWordChips[missingChipIndex] = .empty
            state.validationWords.append(ValidationWord(groupIndex: group, word: word))

            if state.isComplete {
                let value: RecoveryPhraseValidationFlowReducer.Action = state.isValid ? .succeed : .fail
                let effect = Effect<RecoveryPhraseValidationFlowReducer.Action, Never>(value: value)
                    .delay(for: 1, scheduler: mainQueue)
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
            feedbackGenerator.generateErrorFeedback()

        case .updateRoute(let route):
            guard let route = route else {
                state = randomRecoveryPhrase.random(state.phrase)
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

extension RecoveryPhraseValidationFlowReducer.State {
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

// MARK: - ViewStore

extension RecoveryPhraseValidationFlowViewStore {
    func bindingForRoute(_ route: RecoveryPhraseValidationFlowReducer.State.Route) -> Binding<Bool> {
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

extension RecoveryPhraseValidationFlowReducer.State {
    static let placeholder = RecoveryPhraseValidationFlowReducer.State(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .unassigned(word: "thank"),
            .unassigned(word: "morning"),
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [],
        route: nil
    )

    static let placeholderStep1 = RecoveryPhraseValidationFlowReducer.State(
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

    static let placeholderStep2 = RecoveryPhraseValidationFlowReducer.State(
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

    static let placeholderStep3 = RecoveryPhraseValidationFlowReducer.State(
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

    static let placeholderStep4 = RecoveryPhraseValidationFlowReducer.State(
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
    static let demo = Store(
        initialState: .placeholder,
        reducer: RecoveryPhraseValidationFlowReducer()
    )
    
    static let demoStep1 = Store(
        initialState: .placeholderStep1,
        reducer: RecoveryPhraseValidationFlowReducer()
    )

    static let demoStep2 = Store(
        initialState: .placeholderStep1,
        reducer: RecoveryPhraseValidationFlowReducer()
    )

    static let demoStep3 = Store(
        initialState: .placeholderStep3,
        reducer: RecoveryPhraseValidationFlowReducer()
    )

    static let demoStep4 = Store(
        initialState: .placeholderStep4,
        reducer: RecoveryPhraseValidationFlowReducer()
    )
}
