//
//  RecoveryPhrase.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation

enum RecoveryPhraseError: Error {
    /// This error is thrown then the Recovery Phrase can't be generated
    case unableToGeneratePhrase
}

struct RecoveryPhrase: Equatable {
    struct Group: Hashable {
        var startIndex: Int
        var words: [String]
    }

    let words: [String]
    
    private let groupSize = 6

    func toGroups() -> [Group] {
        let chunks = words.count / groupSize
        return zip(0 ..< chunks, words.chunked(into: groupSize)).map {
            Group(startIndex: $0 * groupSize + 1, words: $1)
        }
    }

    func toString() -> String {
        words.joined(separator: " ")
    }

    func words(fromMissingIndices indices: [Int]) -> [PhraseChip.Kind] {
        assert((indices.count - 1) * groupSize <= self.words.count)

        return indices.enumerated().map { index, position in
            .unassigned(word: self.words[(index * groupSize) + position])
        }
    }
}
