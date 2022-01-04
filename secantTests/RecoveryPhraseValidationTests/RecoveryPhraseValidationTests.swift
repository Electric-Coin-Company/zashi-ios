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

        let initialStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordChips,
            fulfillments: []
        )

        let expectedStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [RecoveryPhraseStepFulfillment(groupIndex: 1, word: "salute")]
        )

        let result = initialStep.apply(chip: missingWordChips[0], into: 1)

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

        let initialStep = RecoveryPhraseValidationState.initial(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordsChips: missingWordChips
        )

        let expectedMissingChips = [
            PhraseChip.Kind.unassigned(word: "salute"),
            PhraseChip.Kind.unassigned(word: "boil"),
            PhraseChip.Kind.unassigned(word: "cancel"),
            PhraseChip.Kind.empty
        ]

        let expectedCompletion = [RecoveryPhraseStepFulfillment(groupIndex: 0, word: "pizza")]
        let expectedStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: expectedMissingChips,
            fulfillments: expectedCompletion
        )

        let result = initialStep.apply(chip: missingWordChips[3], into: 0)

        XCTAssertEqual(expectedStep, result)
        XCTAssertEqual(result.step, .incomplete)
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

        let currentStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "boil"),
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute")]
        )
        let expected = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil")
            ]
        )

        let result = currentStep.apply(chip: PhraseChip.Kind.unassigned(word: "boil"), into: 1)

        XCTAssertEqual(expected, result)
        XCTAssertEqual(expected.step, result.step)
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

        let currentStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "cancel"),
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil")
            ]
        )

        let expected = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel")
            ]
        )

        let result = currentStep.apply(chip: PhraseChip.Kind.unassigned(word: "cancel"), into: 2)

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

        let currentStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel")
            ]
        )

        let expected = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel"),
                RecoveryPhraseStepFulfillment(groupIndex: 3, word: "pizza")
            ]
        )

        let result = currentStep.apply(chip: PhraseChip.Kind.unassigned(word: "pizza"), into: 3)

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
            RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
            RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
            RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel"),
            RecoveryPhraseStepFulfillment(groupIndex: 3, word: "pizza")
        ]

        let result = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: RecoveryPhraseValidationState.pickWordsFromMissingIndices(indices: missingIndices, phrase: phrase),
            fulfillments: completion,
            route: nil
        )

        XCTAssertEqual(words, result.resultingPhrase)
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

        let currentStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toChunks()[0]
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

        let currentStep = RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: [
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.empty,
                PhraseChip.Kind.unassigned(word: "pizza")
            ],
            fulfillments: [
                RecoveryPhraseStepFulfillment(groupIndex: 0, word: "salute"),
                RecoveryPhraseStepFulfillment(groupIndex: 1, word: "boil"),
                RecoveryPhraseStepFulfillment(groupIndex: 2, word: "cancel")
            ]
        )

        let result = currentStep.wordsChips(
            for: 0,
            groupSize: 6,
            from: phrase.toChunks()[0]
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

extension RecoveryPhraseValidationState {
    static func initial(
        phrase: RecoveryPhrase,
        missingIndices: [Int],
        missingWordsChips: [PhraseChip.Kind]
    ) -> Self {
        RecoveryPhraseValidationState(
            phrase: phrase,
            missingIndices: missingIndices,
            missingWordChips: missingWordsChips,
            fulfillments: []
        )
    }
}
