//
//  RecoveryPhraseValidationTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 10/29/21.
//
// swiftlint:disable type_body_length
import XCTest
import ComposableArchitecture
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

        let phrase = RecoveryPhrase(words: words)

        let indices = [1, 0, 5, 3]

        let expected = ["salute", "boil", "cancel", "pizza"].map({ PhraseChip.Kind.unassigned(word: $0) })

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

        let phrase = RecoveryPhrase(words: words)

        let missingWordChips: [PhraseChip.Kind] = ["salute", "boil", "cancel", "pizza"].map({ PhraseChip.Kind.unassigned(word: $0) })

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
            PhraseChip.Kind.unassigned(word: "boil"),
            PhraseChip.Kind.unassigned(word: "cancel"),
            PhraseChip.Kind.unassigned(word: "pizza")
        ]

        let expectedValidationWords = [ValidationWord(groupIndex: 1, word: "salute")]

        store.send(.move(wordChip: .unassigned(word: "salute"), intoGroup: 1)) {
            $0.validationWords = expectedValidationWords
            $0.missingWordChips = expectedMissingChips

            XCTAssertFalse($0.isComplete)
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

        let phrase = RecoveryPhrase(words: words)

        let missingWordChips = ["salute", "boil", "cancel", "pizza"].map({ PhraseChip.Kind.unassigned(word: $0) })

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
            PhraseChip.Kind.unassigned(word: "salute"),
            PhraseChip.Kind.unassigned(word: "boil"),
            PhraseChip.Kind.unassigned(word: "cancel"),
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [ValidationWord(groupIndex: 0, word: "pizza")]

        store.send(.move(wordChip: missingWordChips[3], intoGroup: 0)) {
            $0.missingWordChips = expectedMissingChips
            $0.validationWords = expectedValidationWords

            XCTAssertFalse($0.isComplete)
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [ValidationWord(groupIndex: 0, word: "salute")]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        )

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.unassigned(word: "cancel"),
            PhraseChip.Kind.unassigned(word: "pizza")
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute"),
            ValidationWord(groupIndex: 1, word: "boil")
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "boil"), intoGroup: 1)) {
            $0.missingWordChips = expectedMissingWordChips
            $0.validationWords = expectedValidationWords

            XCTAssertFalse($0.isComplete)
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 1, word: "boil")
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
            PhraseChip.Kind.unassigned(word: "pizza")
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute"),
            ValidationWord(groupIndex: 1, word: "boil"),
            ValidationWord(groupIndex: 2, word: "cancel")
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "cancel"), intoGroup: 2)) {
            $0.missingWordChips = expectedMissingWordChips
            $0.validationWords = expectedValidationWords

            XCTAssertFalse($0.isComplete)
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 1, word: "boil"),
                ValidationWord(groupIndex: 2, word: "cancel")
            ]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        ) {
            $0.mainQueue = Self.testScheduler.eraseToAnyScheduler()
        }

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute"),
            ValidationWord(groupIndex: 1, word: "boil"),
            ValidationWord(groupIndex: 2, word: "cancel"),
            ValidationWord(groupIndex: 3, word: "pizza")
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "pizza"), intoGroup: 3)) {
            $0.missingWordChips = expectedMissingWordChips
            $0.validationWords = expectedValidationWords

            XCTAssertTrue($0.isComplete)
            XCTAssertTrue($0.isValid)
        }

        Self.testScheduler.advance(by: 2)

        store.receive(.succeed) {
            XCTAssertTrue($0.isComplete)
            $0.destination = .success
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 2, word: "boil"),
                ValidationWord(groupIndex: 1, word: "cancel")
            ]
        )

        let store = TestStore(
            initialState: currentStep,
            reducer: RecoveryPhraseValidationFlowReducer()
        ) { dependencies in
            dependencies.feedbackGenerator = .noOp
            dependencies.mainQueue = Self.testScheduler.eraseToAnyScheduler()
        }

        let expectedMissingWordChips = [
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty,
            PhraseChip.Kind.empty
        ]

        let expectedValidationWords = [
            ValidationWord(groupIndex: 0, word: "salute"),
            ValidationWord(groupIndex: 2, word: "boil"),
            ValidationWord(groupIndex: 1, word: "cancel"),
            ValidationWord(groupIndex: 3, word: "pizza")
        ]

        store.send(.move(wordChip: PhraseChip.Kind.unassigned(word: "pizza"), intoGroup: 3)) {
            $0.missingWordChips = expectedMissingWordChips
            $0.validationWords = expectedValidationWords

            XCTAssertTrue($0.isComplete)
        }

        Self.testScheduler.advance(by: 2)

        store.receive(.failureFeedback)

        store.receive(.fail) {
            $0.destination = .failure
            XCTAssertFalse($0.isValid)
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 1, word: "boil"),
                ValidationWord(groupIndex: 2, word: "cancel")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toGroups()[0]
        )

        let expected = [
            PhraseChip.Kind.ordered(position: 1, word: "bring"),
            .empty,
            .ordered(position: 3, word: "thank"),
            .ordered(position: 4, word: "require"),
            .ordered(position: 5, word: "spirit"),
            .ordered(position: 6, word: "toe")
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 1, word: "boil"),
                ValidationWord(groupIndex: 2, word: "cancel")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toGroups()[0]
        )

        let expected = [
            PhraseChip.Kind.ordered(position: 1, word: "bring"),
            .unassigned(word: "salute"),
            .ordered(position: 3, word: "thank"),
            .ordered(position: 4, word: "require"),
            .ordered(position: 5, word: "spirit"),
            .ordered(position: 6, word: "toe")
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 1, word: "boil"),
                ValidationWord(groupIndex: 2, word: "cancel")
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

        let phrase = RecoveryPhrase(words: words)

        let currentStep = RecoveryPhraseValidationFlowReducer.State(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            validationWords: [
                ValidationWord(groupIndex: 0, word: "salute"),
                ValidationWord(groupIndex: 1, word: "boil"),
                ValidationWord(groupIndex: 2, word: "cancel")
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

        let phrase = RecoveryPhrase(words: words)

        let completion = [
            ValidationWord(groupIndex: 0, word: "salute"),
            ValidationWord(groupIndex: 1, word: "boil"),
            ValidationWord(groupIndex: 2, word: "cancel"),
            ValidationWord(groupIndex: 3, word: "pizza")
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
        XCTAssertEqual(words, result.resultingPhrase)
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

        let phrase = RecoveryPhrase(words: words)

        let completion = [
            ValidationWord(groupIndex: 3, word: "salute"),
            ValidationWord(groupIndex: 1, word: "boil"),
            ValidationWord(groupIndex: 0, word: "cancel"),
            ValidationWord(groupIndex: 2, word: "pizza")
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
        XCTAssertNotEqual(words, result.resultingPhrase)
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
