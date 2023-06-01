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
        importWallet: XCTUnimplemented("\(Self.self).importWallet"),
        exportWallet: XCTUnimplemented("\(Self.self).exportWallet", placeholder: .placeholder),
        areKeysPresent: XCTUnimplemented("\(Self.self).areKeysPresent", placeholder: false),
        updateBirthday: XCTUnimplemented("\(Self.self).updateBirthday"),
        markUserPassedPhraseBackupTest: XCTUnimplemented("\(Self.self).markUserPassedPhraseBackupTest"),
        nukeWallet: XCTUnimplemented("\(Self.self).nukeWallet")
    )
}

extension WalletStorageClient {
    public static let noOp = Self(
        importWallet: { _, _, _, _ in },
        exportWallet: { .placeholder },
        areKeysPresent: { false },
        updateBirthday: { _ in },
        markUserPassedPhraseBackupTest: { _ in },
        nukeWallet: { }
    )
}
