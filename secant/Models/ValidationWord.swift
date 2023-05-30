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
struct ValidationWord: Equatable {
    var groupIndex: Int
    var word: RedactableString
}
