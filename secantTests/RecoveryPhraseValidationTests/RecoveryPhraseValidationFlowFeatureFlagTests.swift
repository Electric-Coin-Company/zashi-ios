//
//  RecoveryPhraseValidationFlowFeatureFlagTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 01.03.2023.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

// swiftlint:disable:next type_name
class RecoveryPhraseValidationFlowFeatureFlagTests: XCTestCase {
    override func setUp() {
        super.setUp()

        UserDefaultsWalletConfigStorage().clearAll()
    }

    func testRecoveryPhraseValidationFlowOffByDefault() throws {
        XCTAssertFalse(WalletConfig.default.isEnabled(.testBackupPhraseFlow))
    }

    func testRecoveryPhraseValidationFlow_SkipPuzzleUserConfirmedBackup() {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )

        store.send(.phraseDisplay(.finishedPressed)) { state in
            state.destinationState.internalDestination = .home
            state.destinationState.previousDestination = .welcome
        }
    }

    func testRecoveryPhraseValidationFlow_StartPuzzle() {
        var rootState = RootReducer.State.placeholder

        var defaultRawFlags = WalletConfig.default.flags
        defaultRawFlags[.testBackupPhraseFlow] = true
        rootState.walletConfig = WalletConfig(flags: defaultRawFlags)
        
        let store = TestStore(
            initialState: rootState,
            reducer: RootReducer()
        )

        store.send(.phraseDisplay(.finishedPressed))
    }
    
    func testRecoveryPhraseValidationFlow_SkipPuzzleStartOfTheApp() {
        var rootState = RootReducer.State.placeholder
        rootState.storedWallet = .placeholder

        let store = TestStore(
            initialState: rootState,
            reducer: RootReducer()
        )

        store.dependencies.mainQueue = .immediate
        
        store.send(.initialization(.checkBackupPhraseValidation)) { state in
            state.appInitializationState = .initialized
        }
        
        store.receive(.destination(.updateDestination(.home))) { state in
            state.destinationState.internalDestination = .home
            state.destinationState.previousDestination = .welcome
        }
    }
    
    func testRecoveryPhraseValidationFlow_StartPuzzleStartOfTheApp() {
        var rootState = RootReducer.State.placeholder
        rootState.storedWallet = .placeholder

        var defaultRawFlags = WalletConfig.default.flags
        defaultRawFlags[.testBackupPhraseFlow] = true
        rootState.walletConfig = WalletConfig(flags: defaultRawFlags)

        let store = TestStore(
            initialState: rootState,
            reducer: RootReducer()
        )

        let mnemonic =
            """
            still champion voice habit trend flight \
            survey between bitter process artefact blind \
            carbon truly provide dizzy crush flush \
            breeze blouse charge solid fish spread
            """

        let randomRecoveryPhrase = RecoveryPhraseValidationFlowReducer.State.placeholder
        
        store.dependencies.mainQueue = .immediate
        store.dependencies.mnemonic = .noOp
        store.dependencies.mnemonic.asWords = { _ in mnemonic.components(separatedBy: " ") }
        store.dependencies.randomRecoveryPhrase.random = { _ in randomRecoveryPhrase }

        store.send(.initialization(.checkBackupPhraseValidation)) { state in
            state.appInitializationState = .initialized
            state.phraseDisplayState.phrase = RecoveryPhrase(words: mnemonic.components(separatedBy: " ").map { $0.redacted })
        }
        
        store.receive(.destination(.updateDestination(.phraseDisplay))) { state in
            state.destinationState.internalDestination = .phraseDisplay
            state.destinationState.previousDestination = .welcome
        }
    }
    
    @MainActor func testDidFinishLaunching_to_InitializedWalletPhraseBackupPuzzleOff() async throws {
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

        let appState = RootReducer.State(
            debugState: .placeholder,
            destinationState: .placeholder,
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
            walletConfig: .default,
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

        await store.receive(.destination(.updateDestination(.home))) { state in
            state.destinationState.previousDestination = .welcome
            state.destinationState.internalDestination = .home
        }
        
        await store.finish()
    }
}
