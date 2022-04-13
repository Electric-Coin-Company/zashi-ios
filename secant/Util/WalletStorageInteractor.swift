//
//  WalletStorageInteractor.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03/25/2022.
//

import Foundation
import MnemonicSwift
import ZcashLightClientKit

/// Representation of the wallet stored in the persistent storage (typically keychain, handled by `WalletStorage`).
struct StoredWallet: Codable, Equatable {
    let language: MnemonicLanguageType
    let seedPhrase: String
    let version: Int
    
    var birthday: BlockHeight?
    var hasUserPassedPhraseBackupTest: Bool
}

/// The `WalletStorageInteractor` is a wrapper around the `WalletStorage` type that allows for easy testing.
/// The `WalletStorage` Type is comprised of static functions that take and produce data.  In order
/// to easily produce test data, all of these static functions have been wrapped in function
/// properties that live on the `WalletStorageInteractor` type.  Because of this, you can instantiate
/// the `WalletStorageInteractor` with your own implementation of these functions for testing purposes,
/// or you can use one of the built in static versions of the `WalletStorageInteractor`.
struct WalletStorageInteractor {
    /// Store recovery phrase and optionally even birthday to the secured and persistent storage.
    /// This function creates an instance of `StoredWallet` and automatically handles versioning of the stored data.
    ///
    /// - Parameters:
    ///   - bip39: Mnemonic/Seed phrase from `MnemonicSwift`
    ///   - birthday: BlockHeight from SDK
    ///   - language: Mnemonic's language
    /// - Throws:
    ///   - `WalletStorageError.unsupportedLanguage`:  when mnemonic's language is anything other than English
    ///   - `WalletStorageError.alreadyImported` when valid wallet is already in the storage
    ///   - `WalletStorageError.storageError` when some unrecognized error occured
    let importWallet: (String, BlockHeight?, MnemonicLanguageType, Bool) throws -> Void

    /// Load the representation of the wallet from the persistent and secured storage.
    ///
    /// - Returns: the representation of the wallet from the persistent and secured storage.
    /// - Throws:
    ///   - `WalletStorageError.uninitializedWallet`:  when no wallet's data is found in the keychain.
    ///   - `WalletStorageError.storageError` when some unrecognized error occured.
    ///   - `WalletStorageError.unsupportedVersion` when wallet's version stored in the keychain is outdated.
    let exportWallet: () throws -> StoredWallet

    /// Check if the wallet representation `StoredWallet` is present in the persistent storage.
    ///
    /// - Returns: the information wheather some wallet is stored or is not available
    let areKeysPresent: () throws -> Bool

    /// Update the birthday in the securely stored wallet.
    ///
    /// - Parameters:
    ///   - birthday: BlockHeight from SDK
    /// - Throws:
    ///   - `WalletStorage.KeychainError.encoding`:  when encoding the wallet's data failed.
    ///   - `WalletStorageError.storageError` when some unrecognized error occured.
    let updateBirthday: (BlockHeight) throws -> Void

    /// Update the information that user has passed the recovery phrase backup test.
    /// The fuction doesn't take any parameters, default value is the user hasn't passed the test
    /// and this fucntion only sets the true = fact user passed.
    ///
    /// - Throws:
    ///   - `WalletStorage.KeychainError.encoding`:  when encoding the wallet's data failed.
    ///   - `WalletStorageError.storageError` when some unrecognized error occured.
    let markUserPassedPhraseBackupTest: () throws -> Void

    /// Use carefully: deletes the stored wallet.
    /// There's no fate but what we make for ourselves - Sarah Connor.
    let nukeWallet: () -> Void
}

extension WalletStorageInteractor {
    public static func live(walletStorage: WalletStorage = WalletStorage(secItem: .live)) -> Self {
        Self(
            importWallet: { bip39, birthday, language, hasUserPassedPhraseBackupTest  in
                try walletStorage.importWallet(
                    bip39: bip39,
                    birthday: birthday,
                    language: language,
                    hasUserPassedPhraseBackupTest: hasUserPassedPhraseBackupTest
                )
            },
            exportWallet: {
                try walletStorage.exportWallet()
            },
            areKeysPresent: {
                try walletStorage.areKeysPresent()
            },
            updateBirthday: { birthday in
                try walletStorage.updateBirthday(birthday)
            },
            markUserPassedPhraseBackupTest: {
                try walletStorage.markUserPassedPhraseBackupTest()
            },
            nukeWallet: {
                walletStorage.nukeWallet()
            }
        )
    }
    
    public static let throwing = WalletStorageInteractor(
        importWallet: { _, _, _, _ in
            throw WalletStorage.WalletStorageError.alreadyImported
        },
        exportWallet: {
            throw WalletStorage.WalletStorageError.uninitializedWallet
        },
        areKeysPresent: {
            throw WalletStorage.WalletStorageError.uninitializedWallet
        },
        updateBirthday: { _ in
            throw WalletStorage.KeychainError.encoding
        },
        markUserPassedPhraseBackupTest: {
            throw WalletStorage.KeychainError.encoding
        },
        nukeWallet: { }
    )
}
