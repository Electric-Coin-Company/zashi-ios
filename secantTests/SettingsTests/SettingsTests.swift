//
//  SettingsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 21.07.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class SettingsTests: XCTestCase {
    func testBackupWalletAccessRequest_AuthenticateSuccessPath() throws {
        let testScheduler = DispatchQueue.test
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
            localAuthenticationHandler: LocalAuthenticationHandler(authenticate: {
                Effect(value: Result.success(true))
            }),
            mnemonic: .live,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
            userPreferencesStorage: .mock,
            walletStorage: mockedWalletStorage
        )
        
        let store = TestStore(
            initialState: SettingsState(phraseDisplayState: RecoveryPhraseDisplayState(phrase: nil)),
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        store.send(.backupWalletAccessRequest)
        
        testScheduler.advance(by: 0.1)
        
        store.receive(.authenticate(.success(true)))
        store.receive(.backupWallet) { state in
            state.phraseDisplayState.phrase = RecoveryPhrase(words: mnemonic.components(separatedBy: " "))
        }
        store.receive(.updateRoute(.backupPhrase)) { state in
            state.route = .backupPhrase
        }
    }
    
    func testBackupWalletAccessRequest_AuthenticateFailedPath() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        store.send(.backupWalletAccessRequest)
        
        testScheduler.advance(by: 0.1)
        
        store.receive(.authenticate(.success(false)))
    }
    
    func testRescanBlockchain() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
            userPreferencesStorage: .mock,
            walletStorage: .throwing
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: SettingsReducer.default,
            environment: testEnvironment
        )
        
        store.send(.rescanBlockchain) { state in
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
    
    func testRescanBlockchain_Cancelling() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
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
        
        store.send(.cancelRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_QuickRescanClearance() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
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
        
        store.send(.quickRescan) { state in
            state.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_FullRescanClearance() throws {
        let testScheduler = DispatchQueue.test

        let testEnvironment = SettingsEnvironment(
            localAuthenticationHandler: .unimplemented,
            mnemonic: .mock,
            SDKSynchronizer: TestWrappedSDKSynchronizer(),
            scheduler: testScheduler.eraseToAnyScheduler(),
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
        
        store.send(.fullRescan) { state in
            state.rescanDialog = nil
        }
    }
}
