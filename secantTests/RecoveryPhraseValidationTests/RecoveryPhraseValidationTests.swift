//
//  RecoveryPhraseValidationTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 10/29/21.
//
// swiftlint:disable type_body_length
import XCTest
import ComposableArchitecture
import Models
import UIComponents
import RecoveryPhraseValidationFlow
@testable import secant_testnet

class RecoveryPhraseValidationTests: XCTestCase {
    static let testScheduler = DispatchQueue.test

    func testPickWordsFromMissingIndices() throws {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let indices = [1, 0, 5, 3]

        let expected = [
            "salute".redacted,
            "boil".redacted,
            "cancel".redacted,
            "pizza".redacted
        ].map({ PhraseChip.Kind.unassigned(word: $0) })

        let result = phrase.words(fromMissingIndices: indices)

        XCTAssertEqual(expected, result)
    }

    func testWhenInInitialStepChipIsDraggedIntoGroup1FollowingStepIsIncomplete() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let missingWordChips: [PhraseChip.Kind] = [
            "salute".redacted,
            "boil".redacted,
            "cancel".redacted,
            "pizza".redacted
        ].map({ PhraseChip.Kind.unassigned(word: $0) })

        let initialStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChips,
            validationWords: []
        )

        let store = TestStore(
            initialState: initialStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        let expectedMissingChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.unassigned(word: "boil".redacted),
            PhraseChip.Kind.unassigned(word: "cancel".redacted),
            PhraseChip.Kind.unassigned(word: "pizza".redacted)
        ]

        let expectedValidationWords = [ValidationWord(groupIndex: 1, word: "salute".redacted)]

        store.send(.move(wordChip: .unassigned(word: "salute".redacted), intoGroup: 1)) { state in
            state.validationWords = expectedValidationWords
            state.missingWordChips = expectedMissingChips

            XCTAssertFalse(state.isComplete)
        }
    }

    func testWhenInInitialStepChipIsDraggedIntoGroup0FollowingStepIsIncompleteNextStateIsIncomplete() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let missingWordChips = [
            "salute".redacted,
            "boil".redacted,
            "cancel".redacted,
            "pizza".redacted
        ].map({ PhraseChip.Kind.unassigned(word: $0) })

        let initialStep = RecoveryPhraseValidationFlowReducer.State.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let store = TestStore(
            initialState: initialStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        let expectedMissingChips = [
            PhraseChip.Kind.unassigned(word: "salute".redacted),
            PhraseChip.Kind.unassigned(word: "boil".redacted),
            PhraseChip.Kind.unassigned(word: "cancel".redacted),
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [ValidationWord(groupIndex: 0, word: "pizza".redacted)]

        store.send(.move(wordChip: missingWordChips[3], intoGroup: 0)) { state in
            state.missingWordChips = expectedMissingChips
            state.validationWords = expectedValidationWords

            XCTAssertFalse(state.isComplete)
        }
    }

    func testWhenInIncompleteWith2CompletionsAndAChipIsDroppedInGroup3NextStateIsIncomplete() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil".redacted),
                PhraseChip.Kind.unassigned(word: "cancel".redacted),
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [ValidationWord(groupIndex: 0, word: "salute".redacted)]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.unassigned(word: "cancel".redacted),
            PhraseChip.Kind.unassigned(word: "pizza".redacted)
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute".redacted),
            ValidationWord(groupIndex: 1, word: "boil".redacted)
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "boil".redacted), intoGroup: 1)) { state in
            state.missingWordChips = expectedMissingWordChips
            state.validationWords = expectedValidationWords

            XCTAssertFalse(state.isComplete)
        }
    }

    func testWhenInIncompleteWith2CompletionsAndAChipIsDroppedInGroup2NextStateIsIncomplete() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel".redacted),
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 1, word: "boil".redacted)
            ]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.unassigned(word: "pizza".redacted)
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute".redacted),
            ValidationWord(groupIndex: 1, word: "boil".redacted),
            ValidationWord(groupIndex: 2, word: "cancel".redacted)
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "cancel".redacted), intoGroup: 2)) { state in
            state.missingWordChips = expectedMissingWordChips
            state.validationWords = expectedValidationWords

            XCTAssertFalse(state.isComplete)
        }
    }

    func testWhenInIncompleteWith3CompletionsAndAChipIsDroppedInGroup3NextStateIsComplete() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 1, word: "boil".redacted),
                ValidationWord(groupIndex: 2, word: "cancel".redacted)
            ]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )
            
        store.dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute".redacted),
            ValidationWord(groupIndex: 1, word: "boil".redacted),
            ValidationWord(groupIndex: 2, word: "cancel".redacted),
            ValidationWord(groupIndex: 3, word: "pizza".redacted)
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "pizza".redacted), intoGroup: 3)) { state in
            state.missingWordChips = expectedMissingWordChips
            state.validationWords = expectedValidationWords

            XCTAssertTrue(state.isComplete)
            XCTAssertTrue(state.isValid)
        }

        Self.testScheduler.advance(by: 2)

        store.receive(.succeed) { state in
            XCTAssertTrue(state.isComplete)
            state.destination = .success
        }
    }

    func testWhenInIncompleteWith3CompletionsAndAChipIsDroppedInGroup3NextStateIsFailure() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 2, word: "boil".redacted),
                ValidationWord(groupIndex: 1, word: "cancel".redacted)
            ]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )
        
        store.dependencies.feedbackGenerator = .noOp
        store.dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute".redacted),
            ValidationWord(groupIndex: 2, word: "boil".redacted),
            ValidationWord(groupIndex: 1, word: "cancel".redacted),
            ValidationWord(groupIndex: 3, word: "pizza".redacted)
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "pizza".redacted), intoGroup: 3)) { state in
            state.missingWordChips = expectedMissingWordChips
            state.validationWords = expectedValidationWords

            XCTAssertTrue(state.isComplete)
        }

        Self.testScheduler.advance(by: 2)

        store.receive(.failureFeedback)

        store.receive(.fail) { state in
            state.destination = .failure
            XCTAssertFalse(state.isValid)
        }
    }

    func testWhenAWordGroupDoesNotHaveACompletionItHasAnEmptyChipInTheGivenMissingIndex() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 1, word: "boil".redacted),
                ValidationWord(groupIndex: 2, word: "cancel".redacted)
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toGroups()[0]
        )

        let expected = [
            PhraseChip.Kind.ordered(position: 1, word: "bring".redacted),
            .empty,
            .ordered(position: 3, word: "thank".redacted),
            .ordered(position: 4, word: "require".redacted),
            .ordered(position: 5, word: "spirit".redacted),
            .ordered(position: 6, word: "toe".redacted)
        ]

        XCTAssertEqual(expected, result)
    }

    func testWhenAWordGroupHasACompletionItHasABlueChipWithTheCompletedWordInTheGivenMissingIndex() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 1, word: "boil".redacted),
                ValidationWord(groupIndex: 2, word: "cancel".redacted)
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toGroups()[0]
        )

        let expected = [
            PhraseChip.Kind.ordered(position: 1, word: "bring".redacted),
            .unassigned(word: "salute".redacted),
            .ordered(position: 3, word: "thank".redacted),
            .ordered(position: 4, word: "require".redacted),
            .ordered(position: 5, word: "spirit".redacted),
            .ordered(position: 6, word: "toe".redacted)
        ]

        XCTAssertEqual(expected, result)
    }

    func testWhenRecoveryPhraseValidationStateIsNotCompleteResultingPhraseIsNil() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 1, word: "boil".redacted),
                ValidationWord(groupIndex: 2, word: "cancel".redacted)
            ]
        )

        XCTAssertNil(currentStep.resultingPhrase)
    }

    func testRecoveryPhraseValidationStateIsNotCompleteAndNotValidWhenNotCompleted() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza".redacted)
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute".redacted),
                ValidationWord(groupIndex: 1, word: "boil".redacted),
                ValidationWord(groupIndex: 2, word: "cancel".redacted)
            ]
        )

        XCTAssertFalse(currentStep.isComplete)
        XCTAssertFalse(currentStep.isValid)
    }

    func testCreateResultPhraseFromCompletion() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let completion = [
            ValidationWord(groupIndex: 0, word: "salute".redacted),
            ValidationWord(groupIndex: 1, word: "boil".redacted),
            ValidationWord(groupIndex: 2, word: "cancel".redacted),
            ValidationWord(groupIndex: 3, word: "pizza".redacted)
        ]

        let result = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: phrase.words(fromMissingIndices: missingIndices),
            validationWords: completion,
            destination: nil
        )

        XCTAssertTrue(result.isValid)
        XCTAssertTrue(result.isComplete)
        XCTAssertEqual(words.map { $0.redacted }, result.resultingPhrase)
    }

    func testCreateResultPhraseInvalidPhraseFromCompletion() {
        let words = [
            "bring", "salute", "thank",
            "require", "spirit", "toe",
            // second chunk
            "boil", "hill", "casino",
            "trophy", "drink", "frown",
            // third chunk
            "bird", "grit", "close",
            "morning", "bind", "cancel",
            // Fourth chunk
            "daughter", "salon", "quit",
            "pizza", "just", "garlic"
        ]

        let missingIndices = [1, 0, 5, 3]

        let phrase = RecoveryPhrase(words: words.map { $0.redacted })

        let completion = [
            ValidationWord(groupIndex: 3, word: "salute".redacted),
            ValidationWord(groupIndex: 1, word: "boil".redacted),
            ValidationWord(groupIndex: 0, word: "cancel".redacted),
            ValidationWord(groupIndex: 2, word: "pizza".redacted)
        ]

        let result = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: phrase.words(fromMissingIndices: missingIndices),
            validationWords: completion,
            destination: nil
        )

        XCTAssertFalse(result.isValid)
        XCTAssertTrue(result.isComplete)
        XCTAssertNotEqual(words.map { $0.redacted }, result.resultingPhrase)
    }
}

extension RecoveryPhraseValidationFlowReducer.State {
    static func initial(
        phrase: RecoveryPhrase,
        missingIndices: [Int],
        missingWordsChips: [PhraseChip.Kind]
    ) -> Self {
        RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordsChips,
            validationWords: []
        )
    }
}
