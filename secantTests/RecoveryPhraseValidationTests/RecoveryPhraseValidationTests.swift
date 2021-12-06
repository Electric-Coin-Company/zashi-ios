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

        let initialStep = RecoveryPhraseValidationState.ValidationStep.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let expectedStep = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "salute")],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationState.ValidationStep.given(step: initialStep, apply: missingWordChips[0], into: 1)

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

        let initialStep = RecoveryPhraseValidationState.ValidationStep.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let expectedStep = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "pizza")],
            missingWordsChips: [
                PhraseChip.Kind.unassigned(word: "salute"),
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.empty
            ]
        )

        let result = RecoveryPhraseValidationState.ValidationStep.given(step: initialStep, apply: missingWordChips[3], into: 0)

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

        let currentStep = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute")],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationState.ValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "boil"), into: 1)

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

        let currentStep = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationState.ValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "cancel"), into: 2)

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

        let currentStep = RecoveryPhraseValidationState.ValidationStep.incomplete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 2, word: "cancel")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let expected = RecoveryPhraseValidationState.ValidationStep.complete(
            phrase: phrase,
            missingIndices: missingIndices,
            completion: [
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 2, word: "cancel"),
                RecoveryPhraseValidationState.StepCompletion(groupIndex: 3, word: "pizza")
            ],
            missingWordsChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ]
        )

        let result = RecoveryPhraseValidationState.ValidationStep.given(step: currentStep, apply: PhraseChip.Kind.unassigned(word: "pizza"), into: 3)

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
            RecoveryPhraseValidationState.StepCompletion(groupIndex: 0, word: "salute"),
            RecoveryPhraseValidationState.StepCompletion(groupIndex: 1, word: "boil"),
            RecoveryPhraseValidationState.StepCompletion(groupIndex: 2, word: "cancel"),
            RecoveryPhraseValidationState.StepCompletion(groupIndex: 3, word: "pizza")
        ]

        let result = RecoveryPhraseValidationState.ValidationStep.resultingPhrase(
            from: completion,
            missingIndices: missingIndices,
            originalPhrase: phrase,
            numberOfGroups: 4
        )

        XCTAssertEqual(words, result)
    }
}
