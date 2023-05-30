//
//  StoredWallet.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.05.2022.
//

import Foundation
import ZcashLightClientKit
import MnemonicSwift
import Utils

/// Representation of the wallet stored in the persistent storage (typically keychain, handled by `WalletStorage`).
struct StoredWallet: Codable, Equatable {
    let language: MnemonicLanguageType
    let seedPhrase: SeedPhrase
    let version: Int
    
    var birthday: Birthday?
    var hasUserPassedPhraseBackupTest: Bool
}

extension StoredWallet {
    static let placeholder = Self(
        language: .english,
        seedPhrase: SeedPhrase(RecoveryPhrase.testPhrase.joined(separator: " ")),
        version: 0,
        birthday: Birthday(0),
        hasUserPassedPhraseBackupTest: false
    )
}
