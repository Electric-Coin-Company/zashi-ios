//
//  RecoveryPhraseValidationTests.swift
//  secantTests
//
//  Created by Francisco Gindre on 10/29/21.
//
// swiftlint:disable type_body_length
import XCTest
@testable import secant_testnet
class RecoveryPhraseValidationTests: XCTestCase {
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
        let result = RecoveryPhraseValidationState.pickWordsFromMissingIndices(indices: indices, phrase: phrase)

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

        let missingWordChips = ["salute", "boil", "cancel", "pizza"].map({ PhraseChip.Kind.unassigned(word: $0) })

        let initialStep = RecoveryPhraseValidationStep.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let expectedStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseStepCompletion(groupIndex: 1, word: "salute")],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationStep.given(step: initialStep, apply: missingWordChips[0], into: 1)

        XCTAssertEqual(expectedStep, result)
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

        let initialStep = RecoveryPhraseValidationStep.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let expectedStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseStepCompletion(groupIndex: 0, word: "pizza")],
            missingWordsChips: [
                PhraseChip.Kind.unassigned(word: "salute"),
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.empty
            ]
        )

        let result = RecoveryPhraseValidationStep.given(step: initialStep, apply: missingWordChips[3], into: 0)

        XCTAssertEqual(expectedStep, result)
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

        let currentStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute")],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "boil"), into: 1)

        XCTAssertEqual(expected, result)
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

        let currentStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "cancel"), into: 2)

        XCTAssertEqual(expected, result)
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

        let currentStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationStep.complete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel"),
                RecoveryPhraseStepCompletion(groupIndex: 3, word: "pizza")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "pizza"), into: 3)

        XCTAssertEqual(expected, result)
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
            RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
            RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
            RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel"),
            RecoveryPhraseStepCompletion(groupIndex: 3, word: "pizza")
        ]

        let result = RecoveryPhraseValidationStep.resultingPhrase(
            from: completion,
            missingIndices: missingIndices,
            originalPhrase: phrase,
            numberOfGroups: 4
        )

        XCTAssertEqual(words, result)
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

        let currentStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toChunks()[0],
            with: 1,
            completing: [
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ]
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

        let currentStep = RecoveryPhraseValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toChunks()[0],
            with: 1,
            completing: [
                RecoveryPhraseStepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepCompletion(groupIndex: 2, word: "cancel")
            ]
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
}
