//
//  RecoveryPhrase.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import ZcashLightClientKit
import Utils

enum RecoveryPhraseError: Error {
    /// This error is thrown then the Recovery Phrase can't be generated
    case unableToGeneratePhrase
}

struct RecoveryPhrase: Equatable, Redactable {
    struct Group: Hashable {
        var startIndex: Int
        var words: [RedactableString]
    }

    let words: [RedactableString]
    
    private let groupSize = 6

    func toGroups(groupSizeOverride: Int? = nil) -> [Group] {
        let internalGroupSize = groupSizeOverride ?? groupSize
        let chunks = words.count / internalGroupSize
        return zip(0 ..< chunks, words.chunked(into: internalGroupSize)).map {
            Group(startIndex: $0 * internalGroupSize + 1, words: $1)
        }
    }

    func toString() -> RedactableString {
        let result = words
            .map { $0.data }
            .joined(separator: " ")
        return result.redacted
    }

    func words(fromMissingIndices indices: [Int]) -> [PhraseChip.Kind] {
        assert((indices.count - 1) * groupSize <= self.words.count)

        return indices.enumerated().map { index, position in
            .unassigned(word: self.words[(index * groupSize) + position])
        }
    }
}
