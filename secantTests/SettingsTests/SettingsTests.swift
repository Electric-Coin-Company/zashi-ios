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
                exportLogsState: .placeholder,
                isCrashReportingOn: false,
                phraseDisplayState: RecoveryPhraseDisplayReducer.State(phrase: nil)
            ),
            reducer: SettingsReducer()
        )

        store.dependencies.localAuthentication = .mockAuthenticationSucceeded
        store.dependencies.mnemonic = .noOp
        store.dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
        store.dependencies.walletStorage = mockedWalletStorage

        await store.send(.backupWalletAccessRequest)
        
        await store.receive(.backupWallet) { state in
            state.phraseDisplayState.phrase = RecoveryPhrase(words: mnemonic.components(separatedBy: " ").map { $0.redacted })
        }
        await store.receive(.updateDestination(.backupPhrase)) { state in
            state.destination = .backupPhrase
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer()
        )

        store.dependencies.localAuthentication = .mockAuthenticationFailed

        await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
    
    func testExportLogs_ButtonDisableShareEnable() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                exportLogsState: .placeholder,
                isCrashReportingOn: false,
                phraseDisplayState: .init()
            ),
            reducer: SettingsReducer()
        )
        
        store.dependencies.logsHandler = LogsHandlerClient(exportAndStoreLogs: { _, _, _ in nil })
        
        await store.send(.exportLogs(.start)) { state in
            state.exportLogsState.exportLogsDisabled = true
        }
        
        await store.receive(.exportLogs(.finished(nil))) { state in
            state.exportLogsState.exportLogsDisabled = false
            state.exportLogsState.isSharingLogs = true
        }
    }
    
    func testLogShareFinished() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                exportLogsState: ExportLogsReducer.State(
                    isSharingLogs: true
                ),
                isCrashReportingOn: false,
                phraseDisplayState: .init()
            ),
            reducer: SettingsReducer()
        )
        
        await store.send(.exportLogs(.shareFinished)) { state in
            state.exportLogsState.isSharingLogs = false
        }
    }
}
