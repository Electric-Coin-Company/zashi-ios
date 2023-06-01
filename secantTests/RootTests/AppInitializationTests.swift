//
//  AppInitializationTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 31.05.2022.
//

import XCTest
import ComposableArchitecture
import MnemonicClient
import Models
import UIComponents
import RecoveryPhraseValidationFlow
import Generated
import RecoveryPhraseDisplay
@testable import secant_testnet

class AppInitializationTests: XCTestCase {
    /// This integration test starts with finishing the app launch and triggering bunch of initialization procedures.
    @MainActor func testDidFinishLaunching_to_InitializedWallet() async throws {
        // setup the store and environment to be fully mocked
        let recoveryPhrase = RecoveryPhrase(words: try MnemonicClient.mock.randomMnemonicWords().map { $0.redacted })

        let phraseValidationState = RecoveryPhraseValidationFlowReducer.State(
            phrase: recoveryPhrase,
            missingIndices: [2, 0, 3, 5],
            missingWordChips: [
                .unassigned(word: "voice".redacted),
                .empty,
                .unassigned(word: "survey".redacted),
                .unassigned(word: "spread".redacted)
            ],
            validationWords: [
                .init(groupIndex: 2, word: "dizzy".redacted)
            ],
            destination: nil
        )

        let recoveryPhraseRandomizer = RecoveryPhraseRandomizerClient(
            random: { _ in
                let missingIndices = [2, 0, 3, 5]
                let missingWordChipKind = [
                    PhraseChip.Kind.unassigned(
                        word: "voice".redacted,
                        color: Asset.Colors.Buttons.activeButton.color
                    ),
                    PhraseChip.Kind.empty,
                    PhraseChip.Kind.unassigned(
                        word: "survey".redacted,
                        color: Asset.Colors.Buttons.activeButton.color
                    ),
                    PhraseChip.Kind.unassigned(
                        word: "spread".redacted,
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
                            word: "dizzy".redacted
                        )
                    ]
                )
            }
        )

        var defaultRawFlags = WalletConfig.default.flags
        defaultRawFlags[.testBackupPhraseFlow] = true
        let walletConfig = WalletConfig(flags: defaultRawFlags)

        let appState = RootReducer.State(
            debugState: .placeholder,
            destinationState: .placeholder,
            exportLogsState: .placeholder,
            homeState: .placeholder,
            onboardingState: .init(
                walletConfig: .default,
                importWalletState: .placeholder
            ),
            phraseValidationState: phraseValidationState,
            phraseDisplayState: RecoveryPhraseDisplayReducer.State(
                phrase: recoveryPhrase
            ),
            sandboxState: .placeholder,
            walletConfig: walletConfig,
            welcomeState: .placeholder
        )

        let store = TestStore(
            initialState: appState,
            reducer: RootReducer()
        )
        
        let testQueue = DispatchQueue.test
        
        store.dependencies.databaseFiles = .noOp
        store.dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mainQueue = .immediate// testQueue.eraseToAnyScheduler()
        store.dependencies.mnemonic = .mock
        store.dependencies.randomRecoveryPhrase = recoveryPhraseRandomizer
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }
        store.dependencies.walletConfigProvider = .noOp
        store.dependencies.sdkSynchronizer = .noOp

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        await store.send(.initialization(.appDelegate(.didFinishLaunching)))

        await testQueue.advance(by: 0.02)

        await store.receive(.initialization(.checkWalletConfig))
        
        await store.receive(.walletConfigLoaded(WalletConfig.default))

        await store.receive(.initialization(.initialSetups))

        await testQueue.advance(by: 0.02)

        await store.receive(.initialization(.configureCrashReporter))

        await store.receive(.initialization(.checkWalletInitialization))

        await store.receive(.initialization(.respondToWalletInitializationState(.initialized)))

        await testQueue.advance(by: 3.00)

        await store.receive(.initialization(.initializeSDK)) { state in
            state.storedWallet = .placeholder
        }

        await store.receive(.initialization(.checkBackupPhraseValidation)) { state in
            state.appInitializationState = .initialized
        }

        await store.receive(.destination(.updateDestination(.phraseDisplay))) { state in
            state.destinationState.previousDestination = .welcome
            state.destinationState.internalDestination = .phraseDisplay
        }
        
        await store.finish()
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored but database files are present.
    @MainActor func testDidFinishLaunching_to_KeysMissing() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )

        store.dependencies.databaseFiles = .noOp
        store.dependencies.databaseFiles.areDbFilesPresentFor = { _ in true }
        store.dependencies.walletStorage = .noOp
        store.dependencies.mainQueue = .immediate
        store.dependencies.walletConfigProvider = .noOp

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        await store.send(.initialization(.appDelegate(.didFinishLaunching)))

        await store.receive(.initialization(.checkWalletConfig))
        
        await store.receive(.walletConfigLoaded(WalletConfig.default))

        await store.receive(.initialization(.initialSetups))

        await store.receive(.initialization(.configureCrashReporter))

        await store.receive(.initialization(.checkWalletInitialization))

        await store.receive(.initialization(.respondToWalletInitializationState(.keysMissing))) { state in
            state.appInitializationState = .keysMissing
        }
        
        await store.receive(.alert(.root(.walletStateFailed(.keysMissing)))) { state in
            state.uniAlert = AlertState(
                title: TextState("Wallet initialisation failed."),
                message: TextState("App initialisation state: keysMissing."),
                dismissButton: .default(TextState("Ok"), action: .send(.dismissAlert))
            )
        }
        
        await store.finish()
    }
    
    /// Integration test validating the side effects work together properly when no wallet is stored and no database files are present.
    @MainActor func testDidFinishLaunching_to_Uninitialized() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        store.dependencies.databaseFiles = .noOp
        store.dependencies.mainQueue = .immediate
        store.dependencies.walletStorage = .noOp
        store.dependencies.walletConfigProvider = .noOp

        // Root of the test, the app finished the launch process and triggers the checks and initializations.
        await store.send(.initialization(.appDelegate(.didFinishLaunching)))

        await store.receive(.initialization(.checkWalletConfig))

        await store.receive(.walletConfigLoaded(WalletConfig.default))

        await store.receive(.initialization(.initialSetups))

        await store.receive(.initialization(.configureCrashReporter))

        await store.receive(.initialization(.checkWalletInitialization))

        await store.receive(.initialization(.respondToWalletInitializationState(.uninitialized)))
        
        await store.receive(.destination(.updateDestination(.onboarding))) { state in
            state.destinationState.previousDestination = .welcome
            state.destinationState.internalDestination = .onboarding
        }
        
        await store.finish()
    }
}
