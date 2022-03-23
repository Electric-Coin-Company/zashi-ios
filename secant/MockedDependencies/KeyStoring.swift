//
//  KeyStoring.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation
import MnemonicSwift

/// Representation of the wallet stored in the persistent storage (typically keychain, handled by `RecoveryPhraseStorage`).
struct StoredWallet: Codable, Equatable {
    var birthday: BlockHeight?
    let language: MnemonicLanguageType
    let seedPhrase: String
    let version: Int
}

protocol KeyStoring {
    /**
    Store recovery phrase and optionally even birthday to the secured and persistent storage.
    This function creates an instance of `StoredWallet` and automatically handles versioning of the stored data.
    */
    func importRecoveryPhrase(bip39 phrase: String, birthday: BlockHeight?, language: MnemonicLanguageType) throws

    /**
    Load the representation of the wallet from the persistent and secured storage.
    */
    func exportWallet() throws -> StoredWallet

    /**
    Check if the wallet representation `StoredWallet` is present in the persistent storage.
    */
    func areKeysPresent() throws -> Bool

    /**
    Update the birthday in the securely stored wallet.
    */
    func updateBirthday(_ height: BlockHeight) throws

    /**
    Use carefully: deletes the stored wallet.
    There's no fate but what we make for ourselves - Sarah Connor.
    */
    func nukeWallet()
}

enum KeyStoringError: Error {
    case alreadyImported
    case uninitializedWallet
    case storageError(Error)
    case unsupportedVersion(Int)
    case unsupportedLanguage(MnemonicLanguageType)
}
