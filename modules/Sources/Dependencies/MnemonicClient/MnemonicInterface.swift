//
//  MnemonicInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    public var mnemonic: MnemonicClient {
        get { self[MnemonicClient.self] }
        set { self[MnemonicClient.self] = newValue }
    }
}

public struct MnemonicClient {
    /// Random 24 words mnemonic phrase
    public var randomMnemonic: () throws -> String
    /// Random 24 words mnemonic phrase as array of words
    public var randomMnemonicWords: () throws -> [String]
    /// Generate deterministic seed from mnemonic phrase
    public var toSeed: (String) throws -> [UInt8]
    /// Get this mnemonic phrase as array of words
    public var asWords: (String) -> [String]
    /// Validates whether the given mnemonic is correct
    public var isValid: (String) throws -> Void
}
