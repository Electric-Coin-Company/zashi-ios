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
        
        let mockedWalletStorage = WrappedWalletStorage(
            importWallet: { _, _, _, _ in
                throw WalletStorage.WalletStorageError.alreadyImported
            },
            exportWallet: {
                StoredWallet(
                    language: .english,
                    seedPhrase: mnemonic,
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
            markUserPassedPhraseBackupTest: {
                throw WalletStorage.KeychainError.encoding
            },
            nukeWallet: { }
        )
        
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: LocalAuthenticationHandler(authenticate: { true }),
            mnemonic: .live,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: mockedWalletStorage
        )
        
        let store = TestStore(
            initialState: SettingsState(phraseDisplayState: RecoveryPhraseDisplayState(phrase: nil)),
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.backupWalletAccessRequest)
        
        await store.receive(.backupWallet) { state in
            state.phraseDisplayState.phrase = RecoveryPhrase(words: mnemonic.components(separatedBy: " "))
        }
        await store.receive(.updateRoute(.backupPhrase)) { state in
            state.route = .backupPhrase
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() async throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.backupWalletAccessRequest)
        
        await store.finish()
    }
    
    func testRescanBlockchain() async throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.rescanBlockchain) { state in
            state.rescanDialog = .init(
                title: TextState("Rescan"),
                message: TextState("Select the rescan you want"),
                buttons: [
                    .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                    .default(TextState("Full rescan"), action: .send(.fullRescan)),
                    .cancel(TextState("Cancel"))
                ]
            )
        }
    }
    
    func testRescanBlockchain_Cancelling() async throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: SettingsState(
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                route: nil
            ),
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.cancelRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_QuickRescanClearance() async throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: SettingsState(
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                route: nil
            ),
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.quickRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_FullRescanClearance() async throws {
        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: SettingsState(
                phraseDisplayState: .init(),
                rescanDialog: .init(
                    title: TextState("Rescan"),
                    message: TextState("Select the rescan you want"),
                    buttons: [
                        .default(TextState("Quick rescan"), action: .send(.quickRescan)),
                        .default(TextState("Full rescan"), action: .send(.fullRescan)),
                        .cancel(TextState("Cancel"))
                    ]
                ),
                route: nil
            ),
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        await store.send(.fullRescan) { state in
            state.rescanDialog = nil
        }
    }
}
