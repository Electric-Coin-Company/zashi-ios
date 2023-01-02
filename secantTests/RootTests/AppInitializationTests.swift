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
    /// This integration test starts with finishing the app launch and triggering bunch of initialization procedures.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfully operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    /// 3. The .initializeSDK is triggered to set the state of the app and preparing the synchronizer.
    /// 4. The .checkBackupPhraseValidation is triggered to check the validation state.
    /// 5. The user hasn't finished the backup phrase test so the display phrase is presented.
    @MainActor func testDidFinishLaunching_to_InitializedWallet() async throws {
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
            destination: nil
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

        let appState = RootReducer.State(
            destinationState: .placeholder,
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
            reducer: RootReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
            dependencies.derivationTool = .liveValue
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.mnemonic = .mock
            dependencies.randomRecoveryPhrase = recoveryPhraseRandomizer
            dependencies.walletStorage.exportWallet = { .placeholder }
            dependencies.walletStorage.areKeysPresent = { true }
        }

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        _ = await store.send(.initialization(.appDelegate(.didFinishLaunching)))

        // the 0.02 delay ensures keychain is ready
        await testScheduler.advance(by: 0.02)

        // ad 1.
        await store.receive(.initialization(.checkWalletInitialization))

        // ad 2.
        await store.receive(.initialization(.respondToWalletInitializationState(.initialized)))

        // ad 3.
        await store.receive(.initialization(.initializeSDK)) { state in
            state.storedWallet = .placeholder
        }
        // ad 4.
        await store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            state.appInitializationState = .initialized
        }

        // the 3.0 delay ensures the welcome screen is visible till the initialization is done
        await testScheduler.advance(by: 3.00)

        // ad 5.
        await store.receive(.destination(.updateDestination(.phraseDisplay))) { state in
            state.destinationState.previousDestination = .welcome
            state.destinationState.internalDestination = .phraseDisplay
        }
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored but database files are present.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfully operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    func testDidFinishLaunching_to_KeysMissing() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.walletStorage = .noOp
        }

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        store.send(.initialization(.appDelegate(.didFinishLaunching)))
        
        // the 0.02 delay ensures keychain is ready
        testScheduler.advance(by: 0.02)
        
        // ad 1.
        store.receive(.initialization(.checkWalletInitialization))

        // ad 2.
        store.receive(.initialization(.respondToWalletInitializationState(.keysMissing))) { state in
            state.appInitializationState = .keysMissing
        }
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored and no database files are present.
    /// 1. The app calls .checkWalletInitialization delayed by 0.02 seconds to ensure keychain is successfully operational.
    /// 2. The .respondToWalletInitializationState is triggered to decide the state of the wallet.
    /// 3. The wallet is not present, onboarding flow is triggered.
    func testDidFinishLaunching_to_Uninitialized() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        ) { dependencies in
            dependencies.databaseFiles = .noOp
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.walletStorage = .noOp
        }

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        store.send(.initialization(.appDelegate(.didFinishLaunching)))
        
        // the 0.02 delay ensures keychain is ready
        // the 3.0 delay ensures the welcome screen is visible till the initialization check is done
        testScheduler.advance(by: 3.02)
        
        // ad 1.
        store.receive(.initialization(.checkWalletInitialization))

        // ad 2.
        store.receive(.initialization(.respondToWalletInitializationState(.uninitialized)))
        
        // ad 3.
        store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.previousDestination = .welcome
            state.destinationState.internalDestination = .onboarding
        }
    }
}
