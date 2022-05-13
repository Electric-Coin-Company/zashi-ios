//
//  StoredWallet.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.05.2022.
//

import Foundation
import ZcashLightClientKit
import MnemonicSwift

/// Representation of the wallet stored in the persistent storage (typically keychain, handled by `WalletStorage`).
struct StoredWallet: Codable, Equatable {
    let language: MnemonicLanguageType
    let seedPhrase: String
    let version: Int
    
    var birthday: BlockHeight?
    var hasUserPassedPhraseBackupTest: Bool
}
