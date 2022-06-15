//
//  AppInitializationTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 31.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class AppInitializationTests: XCTestCase {
    var storage = WalletStorage(secItem: .live)
    
    override func setUp() {
        super.setUp()
        storage.zcashStoredWalletPrefix = "test_app_"
        storage.deleteData(forKey: WalletStorage.Constants.zcashStoredWallet)
    }

    /// This integration test starts with finishing the app launch and triggering bunch of initialization proceedures.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfuly operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    /// 3. The .initializeSDK is triggered to set the state of the app and preparing the synchronizer.
    /// 4. The .checkBackupPhraseValidation is triggered to check the validation state.
    /// 5. The user hasn't finished the backup phrase test so the display phrase is presented.
    func testDidFinishLaunching_to_InitializedWallet() throws {
        // the test needs to pass the exportWallet() so we simulate some in the keychain
        try storage.importWallet(bip39: "one two three", birthday: nil)
        
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let recoveryPhrase = RecoveryPhrase(words: try WrappedMnemonic.mock.randomMnemonicWords())
        
        let phraseValidationState = RecoveryPhraseValidationFlowState(
            phrase: recoveryPhrase,
            missingIndices: [2, 0, 3, 5],
            missingWordChips: [
                .unassigned(word: "voice"),
                .empty,
                .unassigned(word: "survey"),
                .unassigned(word: "spread")
            ],
            validationWords: [
                .init(groupIndex: 2, word: "dizzy")
            ],
            route: nil
        )
        
        let recoveryPhraseRandomizer = WrappedRecoveryPhraseRandomizer(
            random: { _ in
                let missingIndices = [2, 0, 3, 5]
                let missingWordChipKind = [
                    PhraseChip.Kind.unassigned(
                    word: "voice",
                    color: Asset.Colors.Buttons.activeButton.color
                    ),
                    PhraseChip.Kind.empty,
                    PhraseChip.Kind.unassigned(
                    word: "survey",
                    color: Asset.Colors.Buttons.activeButton.color
                    ),
                    PhraseChip.Kind.unassigned(
                    word: "spread",
                    color: Asset.Colors.Buttons.activeButton.color
                    )
                ]

                return RecoveryPhraseValidationFlowState(
                    phrase: recoveryPhrase,
                    missingIndices: missingIndices,
                    missingWordChips: missingWordChipKind,
                    validationWords: [
                        ValidationWord(
                            groupIndex: 2,
                            word: "dizzy"
                        )
                    ]
                )
            }
        )
        
        let emptyURL = URL(fileURLWithPath: "")
        let dbFiles = WrappedDatabaseFiles(
            documentsDirectory: { emptyURL },
            cacheDbURLFor: { _ in emptyURL },
            dataDbURLFor: { _ in emptyURL },
            outputParamsURLFor: { _ in emptyURL },
            pendingDbURLFor: { _ in emptyURL },
            spendParamsURLFor: { _ in emptyURL },
            areDbFilesPresentFor: { _ in true },
            nukeDbFilesFor: { _ in throw DatabaseFiles.DatabaseFilesError.nukeFiles }
        )
        
        let appState = AppState(
            homeState: .placeholder,
            onboardingState: .init(
                importWalletState: .placeholder
            ),
            phraseValidationState: phraseValidationState,
            phraseDisplayState: RecoveryPhraseDisplayState(
                phrase: recoveryPhrase
            ),
            sandboxState: .placeholder,
            welcomeState: .placeholder
        )
        
        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: dbFiles,
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: recoveryPhraseRandomizer,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .live(walletStorage: storage),
            zcashSDKEnvironment: .mainnet
        )

        let store = TestStore(
            initialState: appState,
            reducer: AppReducer.default,
            environment: testEnvironment
        )

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        store.send(.appDelegate(.didFinishLaunching))
        
        // the 0.02 delay ensures keychain is ready
        testScheduler.advance(by: 0.02)
        
        // ad 1.
        store.receive(.checkWalletInitialization)

        // ad 2.
        store.receive(.respondToWalletInitializationState(.initialized))

        // ad 3.
        store.receive(.initializeSDK) { state in
            state.storedWallet = StoredWallet(
                language: .english,
                seedPhrase: "one two three",
                version: 1,
                hasUserPassedPhraseBackupTest: false
            )
        }
        // ad 4.
        store.receive(.checkBackupPhraseValidation) { state in
            state.appInitializationState = .initialized
        }

        // the 3.0 delay ensures the welcome screen is visible till the initialization is done
        testScheduler.advance(by: 3.00)

        // ad 5.
        store.receive(.updateRoute(.phraseDisplay)) { state in
            state.prevRoute = .welcome
            state.internalRoute = .phraseDisplay
        }
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored but database files are present.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfuly operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    func testDidFinishLaunching_to_KeysMissing() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let emptyURL = URL(fileURLWithPath: "")
        let dbFiles = WrappedDatabaseFiles(
            documentsDirectory: { emptyURL },
            cacheDbURLFor: { _ in emptyURL },
            dataDbURLFor: { _ in emptyURL },
            outputParamsURLFor: { _ in emptyURL },
            pendingDbURLFor: { _ in emptyURL },
            spendParamsURLFor: { _ in emptyURL },
            areDbFilesPresentFor: { _ in true },
            nukeDbFilesFor: { _ in throw DatabaseFiles.DatabaseFilesError.nukeFiles }
        )

        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: dbFiles,
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .live(walletStorage: storage),
            zcashSDKEnvironment: .mainnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        store.send(.appDelegate(.didFinishLaunching))
        
        // the 0.02 delay ensures keychain is ready
        testScheduler.advance(by: 0.02)
        
        // ad 1.
        store.receive(.checkWalletInitialization)

        // ad 2.
        store.receive(.respondToWalletInitializationState(.keysMissing)) { state in
            state.appInitializationState = .keysMissing
        }
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored and no database files are present.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfuly operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    /// 3. The wallet is no prosent, onboarding flow is triggered.
    func testDidFinishLaunching_to_Uninitialized() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let testEnvironment = AppEnvironment(
            audioServices: .silent,
            databaseFiles: .throwing,
            deeplinkHandler: .live,
            derivationTool: .live(),
            feedbackGenerator: .silent,
            mnemonic: .mock,
            recoveryPhraseRandomizer: .live,
            scheduler: testScheduler.eraseToAnyScheduler(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            walletStorage: .live(walletStorage: storage),
            zcashSDKEnvironment: .mainnet
        )

        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer.default,
            environment: testEnvironment
        )

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        store.send(.appDelegate(.didFinishLaunching))
        
        // the 0.02 delay ensures keychain is ready
        // the 3.0 delay ensures the welcome screen is visible till the initialization check is done
        testScheduler.advance(by: 3.02)
        
        // ad 1.
        store.receive(.checkWalletInitialization)

        // ad 2.
        store.receive(.respondToWalletInitializationState(.uninitialized))
        
        // ad 3.
        store.receive(.updateRoute(.onboarding)) { state in
            state.prevRoute = .welcome
            state.internalRoute = .onboarding
        }
    }
}
