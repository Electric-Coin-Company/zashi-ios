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
import SupportDataGenerator
import Pasteboard
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
            initialState: AdvancedSettings.State(
                deleteWallet: .initial,
                phraseDisplayState: RecoveryPhraseDisplay.State(phrase: nil),
                privateDataConsentState: .initial,
                serverSetupState: .initial
            )
        ) {
            AdvancedSettings()
        }

        store.dependencies.localAuthentication = .mockAuthenticationSucceeded
        store.dependencies.mnemonic = .noOp
        store.dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
        store.dependencies.walletStorage = mockedWalletStorage

        await store.send(.backupWalletAccessRequest)
        
        await store.receive(.updateDestination(.backupPhrase)) { state in
            state.destination = .backupPhrase
            state.phraseDisplayState.showBackButton = true
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            AdvancedSettings()
        }

        store.dependencies.localAuthentication = .mockAuthenticationFailed

        await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
    
    func testRestoreWalletSubscription() async throws {
        var initialState = SettingsReducer.State.initial
        initialState.isRestoringWallet = false

        let store = TestStore(
            initialState: initialState
        ) {
            SettingsReducer()
        }

        store.dependencies.walletStatusPanel = .noOp
        store.dependencies.walletStatusPanel.value = {
            AsyncStream { continuation in
                continuation.yield(true)
                continuation.finish()
            }
        }
        
        await store.send(.restoreWalletTask)
        
        await store.receive(.restoreWalletValue(true)) { state in
            state.isRestoringWallet = true
        }
        
        await store.finish()
    }
    
    func testCopySupportEmail() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            SettingsReducer()
        }

        let testPasteboard = PasteboardClient.testPasteboard
        store.dependencies.pasteboard = testPasteboard
        
        await store.send(.copyEmail)

        let supportEmail = SupportDataGenerator.Constants.email
        
        XCTAssertEqual(
            testPasteboard.getString()?.data,
            supportEmail,
            "SettingsTests: `testCopySupportEmail` is expected to match the input `\(supportEmail)`"
        )

        await store.finish()
    }
    
    func testSupportDataGeneratorSubject() async throws {
        let generator = SupportDataGenerator.generate()
        
        XCTAssertEqual(generator.subject, "Zashi")
    }

    func testSupportDataGeneratorEmail() async throws {
        let generator = SupportDataGenerator.generate()
        
        XCTAssertEqual(generator.toAddress, "support@electriccoin.co")
    }
}
