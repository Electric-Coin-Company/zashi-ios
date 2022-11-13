//
//  MnemonicInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    var mnemonic: MnemonicClient {
        get { self[MnemonicClient.self] }
        set { self[MnemonicClient.self] = newValue }
    }
}

struct MnemonicClient {
    /// Random 24 words mnemonic phrase
    var randomMnemonic: () throws -> String
    /// Random 24 words mnemonic phrase as array of words
    var randomMnemonicWords: () throws -> [String]
    /// Generate deterministic seed from mnemonic phrase
    var toSeed: (String) throws -> [UInt8]
    /// Get this mnemonic phrase as array of words
    var asWords: (String) throws -> [String]
    /// Validates whether the given mnemonic is correct
    var isValid: (String) throws -> Void
}
