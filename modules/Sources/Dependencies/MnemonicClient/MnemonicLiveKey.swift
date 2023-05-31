//
//  MnemonicLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import MnemonicSwift

extension MnemonicClient: DependencyKey {
    public static let liveValue = Self(
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
}
