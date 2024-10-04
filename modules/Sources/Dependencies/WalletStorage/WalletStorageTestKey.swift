//
//  WalletStorageTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension WalletStorageClient: TestDependencyKey {
    public static let testValue = Self(
        importWallet: unimplemented("\(Self.self).importWallet", placeholder: {}()),
        exportWallet: unimplemented("\(Self.self).exportWallet", placeholder: .placeholder),
        areKeysPresent: unimplemented("\(Self.self).areKeysPresent", placeholder: false),
        updateBirthday: unimplemented("\(Self.self).updateBirthday", placeholder: {}()),
        markUserPassedPhraseBackupTest: unimplemented("\(Self.self).markUserPassedPhraseBackupTest", placeholder: {}()),
        nukeWallet: unimplemented("\(Self.self).nukeWallet", placeholder: {}()),
        importAddressBookEncryptionKeys: unimplemented("\(Self.self).importAddressBookEncryptionKeys", placeholder: {}()),
        exportAddressBookEncryptionKeys: unimplemented("\(Self.self).exportAddressBookEncryptionKeys", placeholder: .empty)
    )
}

extension WalletStorageClient {
    public static let noOp = Self(
        importWallet: { _, _, _, _ in },
        exportWallet: { .placeholder },
        areKeysPresent: { false },
        updateBirthday: { _ in },
        markUserPassedPhraseBackupTest: { _ in },
        nukeWallet: { },
        importAddressBookEncryptionKeys: { _ in },
        exportAddressBookEncryptionKeys: { .empty }
    )
}
