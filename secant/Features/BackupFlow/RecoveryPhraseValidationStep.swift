//
//  RecoveryPhraseValidationStep.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 11/2/21.
//

import Foundation

/**
Represents the completion of a group of recovery words by de addition of one word into the given group
*/
struct RecoveryPhraseStepCompletion: Equatable {
    var groupIndex: Int
    var word: String
}

enum RecoveryPhraseValidationStep: Equatable {
    case initial(phrase: RecoveryPhrase, missingIndices: [Int], missingWordsChips: [PhraseChip.Kind])
    case incomplete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
    case complete(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
    case valid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])
    case invalid(phrase: RecoveryPhrase, missingIndices: [Int], completion: [RecoveryPhraseStepCompletion], missingWordsChips: [PhraseChip.Kind])

    /**
    drives the state machine represented on this Enum by the action of applying a chip into a group of words containing an empty slot that has to be completed
    */
    static func given(step: RecoveryPhraseValidationStep, apply chip: PhraseChip.Kind, into group: Int) -> RecoveryPhraseValidationStep {
        guard case let PhraseChip.Kind.unassigned(word) = chip else { return step }

        switch step {
        case let .initial(phrase, missingIndices, missingWordsChips):
            guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return step }

            var newMissingWords = missingWordsChips
            newMissingWords[missingChipIndex] = .empty

            return .incomplete(
                phrase: phrase,
                missingIndices: missingIndices,
                completion: [RecoveryPhraseStepCompletion(groupIndex: group, word: word)],
                missingWordsChips: newMissingWords
            )

        case let .incomplete(phrase, missingIndices, completion, missingWordsChips):
            guard let missingChipIndex = missingWordsChips.firstIndex(of: chip) else { return step }

            if completion.count < (RecoveryPhraseValidationState.phraseChunks - 1) {
                var newMissingWords = missingWordsChips
                newMissingWords[missingChipIndex] = .empty

                var newCompletionState = Array(completion)
                newCompletionState.append(RecoveryPhraseStepCompletion(groupIndex: group, word: word))

                return .incomplete(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: newCompletionState,
                    missingWordsChips: newMissingWords
                )
            } else {
                var newCompletion = completion
                newCompletion.append(RecoveryPhraseStepCompletion(groupIndex: group, word: word))

                return .complete(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: newCompletion,
                    missingWordsChips: Array(repeating: .empty, count: RecoveryPhraseValidationState.phraseChunks)
                )
            }
        default:
            return step
        }
    }

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
    /**
    validates that the resulting word on the complete state matches the original word and moves the state into either valid or invalid
    */
    mutating func validate() {
        switch self {
        case let .complete(phrase, missingIndices, completion, missingWordsChips):
            let resultingPhrase = Self.resultingPhrase(
                from: completion,
                missingIndices: missingIndices,
                originalPhrase: phrase,
                numberOfGroups: RecoveryPhraseValidationState.phraseChunks
            )

            if resultingPhrase == phrase.words {
                self = .valid(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: completion,
                    missingWordsChips: missingWordsChips
                )
            } else {
                self = .invalid(
                    phrase: phrase,
                    missingIndices: missingIndices,
                    completion: completion,
                    missingWordsChips: missingWordsChips
                )
            }
        default:
            break
        }
    }
}

extension RecoveryPhrase.Chunk {
    func words(with missingIndex: Int) -> [String] {
        var wordsApplyingMissing = self.words
        wordsApplyingMissing[missingIndex] = ""
        return wordsApplyingMissing
    }
}
