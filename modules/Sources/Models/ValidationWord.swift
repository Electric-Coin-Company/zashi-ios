//
//  ValidationWord.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.05.2022.
//

import Foundation
import Utils

/// Represents the data of a word that has been placed into an empty position, that will be used
/// to validate the completed phrase when all ValidationWords have been placed.
public struct ValidationWord: Equatable {
    public var groupIndex: Int
    public var word: RedactableString
    
    public init(groupIndex: Int, word: RedactableString) {
        self.groupIndex = groupIndex
        self.word = word
    }
}
