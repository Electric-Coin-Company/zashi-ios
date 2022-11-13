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

extension WalletStorageClient: DependencyKey {
    static let liveValue = WalletStorageClient.live()

    static func live(walletStorage: WalletStorage = WalletStorage(secItem: .live)) -> Self {
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
}
