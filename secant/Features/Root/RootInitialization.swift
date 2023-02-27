//
//  RootInitialization.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.12.2022.
//

import ComposableArchitecture
import Foundation

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the app/wallet initialization and erasure of the wallet.
extension RootReducer {
    enum InitializationAction: Equatable {
        case appDelegate(AppDelegateAction)
        case checkBackupPhraseValidation
        case checkWalletInitialization
        case configureCrashReporter
        case createNewWallet
        case checkWalletConfig
        case initializeSDK
        case initialSetups
        case nukeWallet
        case nukeWalletRequest
        case respondToWalletInitializationState(InitializationState)
        case walletConfigChanged(WalletConfig)
    }

    enum DebugAction: Equatable {
        case updateFlag(FeatureFlag, Bool)
        case flagUpdated(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func initializationReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case .initialization(.appDelegate(.didFinishLaunching)):
                return EffectTask(value: .initialization(.checkWalletConfig))
                    .delay(for: 0.02, scheduler: mainQueue)
                    .eraseToEffect()

            case .initialization(.checkWalletConfig):
                return .run { send in
                    let walletConfig = await walletConfigProvider.load()
                    if walletConfig == WalletConfig.default {
                        await send(.initialization(.initialSetups))
                    } else {
                        await send(.initialization(.walletConfigChanged(walletConfig)))
                    }
                }
            
            case .initialization(.walletConfigChanged(let walletConfig)):
                updateStateAfterConfigUpdate(state: &state, config: walletConfig)
                return EffectTask(value: .initialization(.initialSetups))
                
            case .initialization(.initialSetups):
                // TODO: [#524] finish all the wallet events according to definition, https://github.com/zcash/secant-ios-wallet/issues/524
                LoggerProxy.event(".appDelegate(.didFinishLaunching)")
                /// We need to fetch data from keychain, in order to be 100% sure the keychain can be read we delay the check a bit
                return .concatenate(
                    EffectTask(value: .initialization(.configureCrashReporter)),
                    EffectTask(value: .initialization(.checkWalletInitialization))
                        .delay(for: 0.02, scheduler: mainQueue)
                        .eraseToEffect()
                )

                /// Evaluate the wallet's state based on keychain keys and database files presence
            case .initialization(.checkWalletInitialization):
                let walletState = RootReducer.walletInitializationState(
                    databaseFiles: databaseFiles,
                    walletStorage: walletStorage,
                    zcashSDKEnvironment: zcashSDKEnvironment
                )
                return EffectTask(value: .initialization(.respondToWalletInitializationState(walletState)))

                /// Respond to all possible states of the wallet and initiate appropriate side effects including errors handling
            case .initialization(.respondToWalletInitializationState(let walletState)):
                switch walletState {
                case .failed:
                    // TODO: [#221] error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.appInitializationState = .failed
                case .keysMissing:
                    // TODO: [#221] error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.appInitializationState = .keysMissing
                case .initialized, .filesMissing:
                    if walletState == .filesMissing {
                        state.appInitializationState = .filesMissing
                    }
                    return .concatenate(
                        EffectTask(value: .initialization(.initializeSDK)),
                        EffectTask(value: .initialization(.checkBackupPhraseValidation))
                    )
                case .uninitialized:
                    state.appInitializationState = .uninitialized
                    return EffectTask(value: .destination(.updateDestination(.onboarding)))
                        .delay(for: 3, scheduler: mainQueue)
                        .eraseToEffect()
                        .cancellable(id: CancelId.self, cancelInFlight: true)
                }

                return .none

                /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
                /// When initialization succeeds user is taken to the home screen.
            case .initialization(.initializeSDK):
                do {
                    state.storedWallet = try walletStorage.exportWallet()

                    guard let storedWallet = state.storedWallet else {
                        state.appInitializationState = .failed
                        // TODO: [#221] fatal error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                        return .none
                    }

                    try mnemonic.isValid(storedWallet.seedPhrase.value())
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())

                    let birthday = state.storedWallet?.birthday?.value() ?? zcashSDKEnvironment.latestCheckpoint

                    let initializer = try RootReducer.prepareInitializer(
                        for: storedWallet.seedPhrase.value(),
                        birthday: birthday,
                        databaseFiles: databaseFiles,
                        derivationTool: derivationTool,
                        mnemonic: mnemonic,
                        zcashSDKEnvironment: zcashSDKEnvironment
                    )
                    
                    try sdkSynchronizer.prepareWith(initializer: initializer, seedBytes: seedBytes)
                    try sdkSynchronizer.start()
                    return .none
                } catch {
                    // TODO: [#221] error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.appInitializationState = .failed
                    return .none
                }

            case .initialization(.checkBackupPhraseValidation):
                guard let storedWallet = state.storedWallet else {
                    state.appInitializationState = .failed
                    // TODO: [#221] fatal error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    return .none
                }

                var landingDestination = RootReducer.DestinationState.Destination.home

                if !storedWallet.hasUserPassedPhraseBackupTest {
                    do {
                        let phraseWords = try mnemonic.asWords(storedWallet.seedPhrase.value())

                        let recoveryPhrase = RecoveryPhrase(words: phraseWords.map { $0.redacted })
                        state.phraseDisplayState.phrase = recoveryPhrase
                        state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)
                        landingDestination = .phraseDisplay
                    } catch {
                        // TODO: [#201] - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                        return .none
                    }
                }

                state.appInitializationState = .initialized

                return EffectTask(value: .destination(.updateDestination(landingDestination)))
                    .delay(for: 3, scheduler: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelId.self, cancelInFlight: true)

            case .initialization(.createNewWallet):
                do {
                    // get the random english mnemonic
                    let newRandomPhrase = try mnemonic.randomMnemonic()
                    let birthday = zcashSDKEnvironment.latestCheckpoint

                    // store the wallet to the keychain
                    try walletStorage.importWallet(newRandomPhrase, birthday, .english, false)

                    // start the backup phrase validation test
                    let randomRecoveryPhraseWords = try mnemonic.asWords(newRandomPhrase)
                    let recoveryPhrase = RecoveryPhrase(words: randomRecoveryPhraseWords.map { $0.redacted })
                    state.phraseDisplayState.phrase = recoveryPhrase
                    state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)

                    return .concatenate(
                        EffectTask(value: .initialization(.initializeSDK)),
                        EffectTask(value: .phraseValidation(.displayBackedUpPhrase))
                    )
                } catch {
                    // TODO: [#201] - merge with issue 221 (https://github.com/zcash/secant-ios-wallet/issues/221) and its Error States
                }

                return .none

            case .phraseValidation(.succeed):
                do {
                    try walletStorage.markUserPassedPhraseBackupTest()
                } catch {
                    // TODO: [#221] error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                return .none

            case .initialization(.nukeWalletRequest):
                state.destinationState.alert = AlertState(
                    title: TextState("Wipe of the wallet"),
                    message: TextState("Are you sure?"),
                    buttons: [
                        .destructive(
                            TextState("Yes"),
                            action: .send(.initialization(.nukeWallet))
                        ),
                        .cancel(
                            TextState("No"),
                            action: .send(.destination(.dismissAlert))
                        )
                    ]
                )
                return .none
            
            case .initialization(.nukeWallet):
                guard let wipePublisher = sdkSynchronizer.wipe() else {
                    return EffectTask(value: .nukeWalletFailed)
                }
                return wipePublisher
                    .catchToEffect()
                    .receive(on: mainQueue)
                    .replaceEmpty(with: .success(Void()))
                    .map { _ in return RootReducer.Action.nukeWalletSucceeded }
                    .replaceError(with: RootReducer.Action.nukeWalletFailed)
                    .eraseToEffect()
                    .cancellable(id: SynchronizerCancelId.self, cancelInFlight: true)

            case .nukeWalletSucceeded:
                walletStorage.nukeWallet()
                state.onboardingState.destination = nil
                state.onboardingState.index = 0
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.self),
                    EffectTask(value: .initialization(.checkWalletInitialization))
                )

            case .nukeWalletFailed:
                // TODO: [#221] error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                let backDestination: EffectTask<RootReducer.Action>
                if let previousDestination = state.destinationState.previousDestination {
                    backDestination = EffectTask(value: .destination(.updateDestination(previousDestination)))
                } else {
                    backDestination = EffectTask(value: .destination(.updateDestination(state.destinationState.destination)))
                }
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.self),
                    backDestination
                )

            case .welcome(.debugMenuStartup), .home(.debugMenuStartup):
                return .concatenate(
                    EffectTask.cancel(id: CancelId.self),
                    EffectTask(value: .destination(.updateDestination(.startup)))
                )

            case .onboarding(.importWallet(.successfullyRecovered)):
                return EffectTask(value: .destination(.updateDestination(.home)))

            case .onboarding(.importWallet(.initializeSDK)):
                return EffectTask(value: .initialization(.initializeSDK))

            case .onboarding(.createNewWallet):
                return EffectTask(value: .initialization(.createNewWallet))
                
            case .home, .destination, .onboarding, .phraseDisplay, .phraseValidation, .sandbox, .welcome, .binding:
                return .none

            case .initialization(.configureCrashReporter):
                crashReporter.configure(
                    !userStoredPreferences.isUserOptedOutOfCrashReporting()
                )
                return .none

            case let .debug(.updateFlag(flag, isEnabled)):
                return .run { send in
                    await walletConfigProvider.update(flag, !isEnabled)
                    let walletConfig = await walletConfigProvider.load()
                    await send(.debug(.flagUpdated(walletConfig)))
                }

            case let .debug(.flagUpdated(walletConfig)):
                updateStateAfterConfigUpdate(state: &state, config: walletConfig)
                return .none
            }
        }
    }

    private func updateStateAfterConfigUpdate(state: inout RootReducer.State, config: WalletConfig) {
        state.walletConfig = config
        state.onboardingState.walletConfig = config
    }
}
