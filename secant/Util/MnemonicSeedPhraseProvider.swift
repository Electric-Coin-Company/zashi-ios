//
//  MnemonicSeedPhraseProvider.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/09/2022.
//

import Foundation
import MnemonicSwift

struct MnemonicSeedPhraseProvider {
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

extension MnemonicSeedPhraseProvider {
    static let live = MnemonicSeedPhraseProvider(
        randomMnemonic: {
            try Mnemonic.generateMnemonic(strength: 256)
        },
        randomMnemonicWords: {
            try Mnemonic.generateMnemonic(strength: 256).components(separatedBy: " ")
        },
        toSeed: { mnemonic in
            let data = try Mnemonic.deterministicSeedBytes(from: mnemonic)

            return [UInt8](data)
        },
        asWords: { mnemonic in
            mnemonic.components(separatedBy: " ")
        },
        isValid: { mnemonic in
            try Mnemonic.validate(mnemonic: mnemonic)
        }
    )
    
    static let mock = MnemonicSeedPhraseProvider(
        randomMnemonic: {
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
        },
        randomMnemonicWords: {
            let mnemonic = """
                still champion voice habit trend flight \
                survey between bitter process artefact blind \
                carbon truly provide dizzy crush flush \
                breeze blouse charge solid fish spread
                """
            
            return mnemonic.components(separatedBy: " ")
        },
        toSeed: { _ in
            let seedString = Data(
                base64Encoded: "9VDVOZZZOWWHpZtq1Ebridp3Qeux5C+HwiRR0g7Oi7HgnMs8Gfln83+/Q1NnvClcaSwM4ADFL1uZHxypEWlWXg=="
            )!// swiftlint:disable:this force_unwrapping
            
            return [UInt8](seedString)
        },
        asWords: { mnemonic in
            let mnemonic = """
                still champion voice habit trend flight \
                survey between bitter process artefact blind \
                carbon truly provide dizzy crush flush \
                breeze blouse charge solid fish spread
                """
            
            return mnemonic.components(separatedBy: " ")
        },
        isValid: { _ in }
    )
}
