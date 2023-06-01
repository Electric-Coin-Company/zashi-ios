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
public struct StoredWallet: Codable, Equatable {
    public let language: MnemonicLanguageType
    public let seedPhrase: SeedPhrase
    public let version: Int
    
    public var birthday: Birthday?
    public var hasUserPassedPhraseBackupTest: Bool
    
    public init(
        language: MnemonicLanguageType,
        seedPhrase: SeedPhrase,
        version: Int,
        birthday: Birthday? = nil,
        hasUserPassedPhraseBackupTest: Bool
    ) {
        self.language = language
        self.seedPhrase = seedPhrase
        self.version = version
        self.birthday = birthday
        self.hasUserPassedPhraseBackupTest = hasUserPassedPhraseBackupTest
    }
}

extension StoredWallet {
    public static let placeholder = Self(
        language: .english,
        seedPhrase: SeedPhrase(RecoveryPhrase.testPhrase.joined(separator: " ")),
        version: 0,
        birthday: Birthday(0),
        hasUserPassedPhraseBackupTest: false
    )
}
