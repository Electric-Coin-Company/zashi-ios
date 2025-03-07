//
//  WalletStorageLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import MnemonicSwift
import ZcashLightClientKit
import ComposableArchitecture
import SecItem

extension WalletStorageClient: DependencyKey {
    public static let liveValue = WalletStorageClient.live()

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
            markUserPassedPhraseBackupTest: { flag in
                try walletStorage.markUserPassedPhraseBackupTest(flag)
            },
            resetZashi: {
                try walletStorage.resetZashi()
            },
            importAddressBookEncryptionKeys: { keys in
                try walletStorage.importAddressBookEncryptionKeys(keys)
            },
            exportAddressBookEncryptionKeys: {
                try walletStorage.exportAddressBookEncryptionKeys()
            },
            importUserMetadataEncryptionKeys: { keys, account in
                try walletStorage.importUserMetadataEncryptionKeys(keys, account: account)
            },
            exportUserMetadataEncryptionKeys: { account in
                try walletStorage.exportUserMetadataEncryptionKeys(account: account)
            }
        )
    }
}
