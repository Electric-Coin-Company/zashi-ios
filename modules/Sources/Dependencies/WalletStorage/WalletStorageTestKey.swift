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
        importAddressBookKey: unimplemented("\(Self.self).importAddressBookKey", placeholder: {}()),
        exportAddressBookKey: unimplemented("\(Self.self).exportAddressBookKey", placeholder: "")
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
        importAddressBookKey: { _ in },
        exportAddressBookKey: { "" }
    )
}
