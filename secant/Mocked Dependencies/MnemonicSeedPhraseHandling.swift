//
//  MnemonicSeedPhraseHandling.swift
//  wallet
//
//  Created by Francisco Gindre on 2/28/20.
//  Copyright © 2020 Francisco Gindre. All rights reserved.
//

import Foundation

enum MnemonicError: Error {
    case invalidSeed
    case checksumFailed
}

protocol MnemonicSeedPhraseHandling {
    /**
    Random 24 words mnemonic phrase
    */
    func randomMnemonic() throws -> String

    /**
    Random 24 words mnemonic phrase as array of words
    */
    func randomMnemonicWords() throws -> [String]

    /**
    Generate deterministic seed from mnemonic phrase
    */
    func toSeed(mnemonic: String) throws -> [UInt8]

    /**
    Get this mnemonic
    */
    func asWords(mnemonic: String) throws -> [String]

    /**
    Validates whether the given mnemonic is correct
    */
    func isValid(mnemonic: String) throws
}
