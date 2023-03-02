//
//  SettingsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

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
                isCrashReportingOn: false,
                phraseDisplayState: RecoveryPhraseDisplayReducer.State(phrase: nil)
            ),
            reducer: SettingsReducer()
        ) { dependencies in
            dependencies.localAuthentication = .mockAuthenticationSucceeded
            dependencies.mnemonic = .noOp
            dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
            dependencies.walletStorage = mockedWalletStorage
        }

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
        ) {
            $0.localAuthentication = .mockAuthenticationFailed
        }

        await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
    
    func testExportLogs_ButtonDisableShareEnable() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                isCrashReportingOn: false,
                phraseDisplayState: .init()
            ),
            reducer: SettingsReducer()
        )
        
        store.dependencies.logsHandler = LogsHandlerClient(exportAndStoreLogs: { _, _, _ in })
        
        await store.send(.exportLogs) { state in
            state.exportLogsDisabled = true
        }
        
        await store.receive(.logsExported) { state in
            state.exportLogsDisabled = false
            state.isSharingLogs = true
        }
    }
    
    func testLogShareFinished() async throws {
        let store = TestStore(
            initialState: SettingsReducer.State(
                destination: nil,
                isCrashReportingOn: false,
                isSharingLogs: true,
                phraseDisplayState: .init()
            ),
            reducer: SettingsReducer()
        )
        
        await store.send(.logsShareFinished) { state in
            state.isSharingLogs = false
        }
    }
}
