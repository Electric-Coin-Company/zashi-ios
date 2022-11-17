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
    /// This integration test starts with finishing the app launch and triggering bunch of initialization proceedures.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfuly operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    /// 3. The .initializeSDK is triggered to set the state of the app and preparing the synchronizer.
    /// 4. The .checkBackupPhraseValidation is triggered to check the validation state.
    /// 5. The user hasn't finished the backup phrase test so the display phrase is presented.
    func testDidFinishLaunching_to_InitializedWallet() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let recoveryPhrase = RecoveryPhrase(words: try MnemonicClient.mock.randomMnemonicWords())
        
        let phraseValidationState = RecoveryPhraseValidationFlowReducer.State(
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
        
        let recoveryPhraseRandomizer = RecoveryPhraseRandomizerClient(
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

                return RecoveryPhraseValidationFlowReducer.State(
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
        
        let appState = AppReducer.State(
            homeState: .placeholder,
            onboardingState: .init(
                importWalletState: .placeholder
            ),
            phraseValidationState: phraseValidationState,
            phraseDisplayState: RecoveryPhraseDisplayReducer.State(
                phrase: recoveryPhrase
            ),
            sandboxState: .placeholder,
            welcomeState: .placeholder
        )
        
        let store = TestStore(
            initialState: appState,
            reducer: AppReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
            dependencies.derivationTool = .noOp
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.mnemonic = .mock
            dependencies.randomRecoveryPhrase = recoveryPhraseRandomizer
            dependencies.walletStorage.exportWallet = { .placeholder }
            dependencies.walletStorage.areKeysPresent = { true }
        }

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
                seedPhrase: "",
                version: 0,
                birthday: 0,
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

        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.walletStorage = .noOp
        }

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

        let store = TestStore(
            initialState: .placeholder,
            reducer: AppReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.walletStorage = .noOp
        }

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
