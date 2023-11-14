//
//  SettingsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
import Utils
import ComposableArchitecture
import LogsHandler
import Models
import WalletStorage
import RecoveryPhraseDisplay
import Settings
import ExportLogs
@testable import secant_testnet

@MainActor
class SettingsTests: XCTestCase {
    func testBackupWalletAccessRequest_AuthenticateSuccessPath() async throws {
        let mnemonic =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """
        
        let mockedWalletStorage = WalletStorageClient(
            importWallet: { _, _, _, _ in
                throw WalletStorage.WalletStorageError.alreadyImported
            },
            exportWallet: {
                StoredWallet(
                    language: .english,
                    seedPhrase: SeedPhrase(mnemonic),
                    version: 1,
                    hasUserPassedPhraseBackupTest: true
                )
            },
            areKeysPresent: {
                throw WalletStorage.WalletStorageError.uninitializedWallet
            },
            updateBirthday: { _ in
                throw WalletStorage.KeychainError.encoding
            },
            markUserPassedPhraseBackupTest: { _ in
                throw WalletStorage.KeychainError.encoding
            },
            nukeWallet: { }
        )
        
        let store = TestStore(
            initialState: SettingsReducer.State(
                phraseDisplayState: RecoveryPhraseDisplayReducer.State(phrase: nil),
                privateDataConsentState: .initial
            ),
            reducer: SettingsReducer(networkType: .testnet)
        )

        store.dependencies.localAuthentication = .mockAuthenticationSucceeded
        store.dependencies.mnemonic = .noOp
        store.dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
        store.dependencies.walletStorage = mockedWalletStorage

        await store.send(.backupWalletAccessRequest)
        
        await store.receive(.updateDestination(.backupPhrase)) { state in
            state.destination = .backupPhrase
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() async throws {
        let store = TestStore(
            initialState: .initial,
            reducer: SettingsReducer(networkType: .testnet)
        )

        store.dependencies.localAuthentication = .mockAuthenticationFailed

        await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
}
