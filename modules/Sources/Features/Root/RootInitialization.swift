//
//  RootInitialization.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.12.2022.
//

import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Models
import Utils

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the app/wallet initialization and erasure of the wallet.
extension RootReducer {
    public enum InitializationAction: Equatable {
        case appDelegate(AppDelegateAction)
        case checkBackupPhraseValidation
        case checkWalletInitialization
        case configureCrashReporter
        case createNewWallet
        case checkWalletConfig
        case initializeSDK(WalletInitMode)
        case initialSetups
        case initializationFailed(ZcashError)
        case nukeWallet
        case nukeWalletRequest
        case respondToWalletInitializationState(InitializationState)
        case synchronizerStartFailed(ZcashError)
        case retryStart
        case walletConfigChanged(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func initializationReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case .initialization(.appDelegate(.didEnterBackground)):
                sdkSynchronizer.stop()
                return .none
                
            case .initialization(.appDelegate(.willEnterForeground)):
                return EffectTask(value: .initialization(.retryStart))
                    .delay(for: 1.0, scheduler: mainQueue)
                    .eraseToEffect()
                
            case .initialization(.synchronizerStartFailed(let zcashError)):
                state.alert = AlertState.retryStartFailed(zcashError)
                return .none

            case .initialization(.retryStart):
                return .run { send in
                    do {
                        try await sdkSynchronizer.start(true)
                    } catch {
                        await send(.initialization(.synchronizerStartFailed(error.toZcashError())))
                    }
                }

            case .initialization(.appDelegate(.didFinishLaunching)):
                // TODO: [#704], trigger the review request logic when approved by the team,
                // https://github.com/zcash/secant-ios-wallet/issues/704
                return EffectTask(value: .initialization(.initialSetups))
                    .delay(for: 0.02, scheduler: mainQueue)
                    .eraseToEffect()

            case .initialization(.checkWalletConfig):
                return walletConfigProvider.load()
                    .receive(on: mainQueue)
                    .map(RootReducer.Action.walletConfigLoaded)
                    .eraseToEffect()
                    .cancellable(id: WalletConfigCancelId.timer, cancelInFlight: true)

            case .walletConfigLoaded(let walletConfig):
                if walletConfig == WalletConfig.default {
                    return EffectTask(value: .initialization(.initialSetups))
                } else {
                    return EffectTask(value: .initialization(.walletConfigChanged(walletConfig)))
                }
            
            case .initialization(.walletConfigChanged(let walletConfig)):
                return .concatenate(
                    EffectTask(value: .updateStateAfterConfigUpdate(walletConfig)),
                    EffectTask(value: .initialization(.initialSetups))
                )
                
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
                    zcashNetwork: zcashNetwork
                )
                return EffectTask(value: .initialization(.respondToWalletInitializationState(walletState)))

                /// Respond to all possible states of the wallet and initiate appropriate side effects including errors handling
            case .initialization(.respondToWalletInitializationState(let walletState)):
                switch walletState {
                case .failed:
                    state.appInitializationState = .failed
                    state.alert = AlertState.walletStateFailed(walletState)
                    return .none
                case .keysMissing:
                    state.appInitializationState = .keysMissing
                    state.alert = AlertState.walletStateFailed(walletState)
                    return .none
                case .initialized, .filesMissing:
                    if walletState == .filesMissing {
                        state.appInitializationState = .filesMissing
                    }
                    return .concatenate(
                        EffectTask(value: .initialization(.initializeSDK(.existingWallet))),
                        EffectTask(value: .initialization(.checkBackupPhraseValidation))
                    )
                case .uninitialized:
                    state.appInitializationState = .uninitialized
                    return EffectTask(value: .destination(.updateDestination(.onboarding)))
                        .delay(for: 3, scheduler: mainQueue)
                        .eraseToEffect()
                        .cancellable(id: CancelId.timer, cancelInFlight: true)
                }

                /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
                /// When initialization succeeds user is taken to the home screen.
            case .initialization(.initializeSDK(let walletMode)):
                do {
                    state.storedWallet = try walletStorage.exportWallet()

                    guard let storedWallet = state.storedWallet else {
                        state.appInitializationState = .failed
                        state.alert = AlertState.cantLoadSeedPhrase()
                        return .none
                    }

                    let birthday = state.storedWallet?.birthday?.value() ?? zcashSDKEnvironment.latestCheckpoint(zcashNetwork)

                    try mnemonic.isValid(storedWallet.seedPhrase.value())
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                    
                    return .run { send in
                        do {
                            try await sdkSynchronizer.prepareWith(seedBytes, birthday, walletMode)
                            try await sdkSynchronizer.start(false)
                        } catch {
                            await send(.initialization(.initializationFailed(error.toZcashError())))
                        }
                    }
                } catch {
                    return EffectTask(value: .initialization(.initializationFailed(error.toZcashError())))
                }

            case .initialization(.checkBackupPhraseValidation):
                guard let storedWallet = state.storedWallet else {
                    state.appInitializationState = .failed
                    state.alert = AlertState.cantLoadSeedPhrase()
                    return .none
                }

                var landingDestination = RootReducer.DestinationState.Destination.home

                if !storedWallet.hasUserPassedPhraseBackupTest && state.walletConfig.isEnabled(.testBackupPhraseFlow) {
                    let phraseWords = mnemonic.asWords(storedWallet.seedPhrase.value())

                    let recoveryPhrase = RecoveryPhrase(words: phraseWords.map { $0.redacted })
                    state.phraseDisplayState.phrase = recoveryPhrase
                    state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)
                    landingDestination = .phraseDisplay
                }

                state.appInitializationState = .initialized

                return EffectTask(value: .destination(.updateDestination(landingDestination)))
                    .delay(for: 3, scheduler: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelId.timer, cancelInFlight: true)

            case .initialization(.createNewWallet):
                do {
                    // get the random english mnemonic
                    let newRandomPhrase = try mnemonic.randomMnemonic()
                    let birthday = zcashSDKEnvironment.latestCheckpoint(zcashNetwork)

                    // store the wallet to the keychain
                    try walletStorage.importWallet(newRandomPhrase, birthday, .english, !state.walletConfig.isEnabled(.testBackupPhraseFlow))

                    // start the backup phrase validation test
                    let randomRecoveryPhraseWords = mnemonic.asWords(newRandomPhrase)
                    let recoveryPhrase = RecoveryPhrase(words: randomRecoveryPhraseWords.map { $0.redacted })
                    state.phraseDisplayState.phrase = recoveryPhrase
                    state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)

                    return .concatenate(
                        EffectTask(value: .initialization(.initializeSDK(.newWallet))),
                        EffectTask(value: .phraseValidation(.displayBackedUpPhrase))
                    )
                } catch {
                    state.alert = AlertState.cantCreateNewWallet(error.toZcashError())
                }
                return .none

            case .phraseValidation(.succeed):
                do {
                    try walletStorage.markUserPassedPhraseBackupTest(true)
                } catch {
                    state.alert = AlertState.cantStoreThatUserPassedPhraseBackupTest(error.toZcashError())
                }
                return .none

            case .initialization(.nukeWalletRequest):
                state.alert = AlertState.wipeRequest()
                return .none
            
            case .initialization(.nukeWallet):
                guard let wipePublisher = sdkSynchronizer.wipe() else {
                    return EffectTask(value: .nukeWalletFailed)
                }
                return wipePublisher
                    .replaceEmpty(with: Void())
                    .map { _ in return RootReducer.Action.nukeWalletSucceeded }
                    .replaceError(with: RootReducer.Action.nukeWalletFailed)
                    .receive(on: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: SynchronizerCancelId.timer, cancelInFlight: true)

            case .nukeWalletSucceeded:
                walletStorage.nukeWallet()
                state.onboardingState.destination = nil
                state.onboardingState.index = 0
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.timer),
                    EffectTask(value: .initialization(.checkWalletInitialization))
                )

            case .nukeWalletFailed:
                let backDestination: EffectTask<RootReducer.Action>
                if let previousDestination = state.destinationState.previousDestination {
                    backDestination = EffectTask(value: .destination(.updateDestination(previousDestination)))
                } else {
                    backDestination = EffectTask(value: .destination(.updateDestination(state.destinationState.destination)))
                }
                state.alert = AlertState.wipeFailed()
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.timer),
                    backDestination
                )

            case .welcome(.debugMenuStartup), .home(.debugMenuStartup):
                return .concatenate(
                    EffectTask.cancel(id: CancelId.timer),
                    EffectTask(value: .destination(.updateDestination(.startup)))
                )

            case .onboarding(.importWallet(.successfullyRecovered)):
                return EffectTask(value: .destination(.updateDestination(.home)))

            case .onboarding(.importWallet(.initializeSDK)):
                return EffectTask(value: .initialization(.initializeSDK(.restoreWallet)))

            case .onboarding(.createNewWallet):
                return EffectTask(value: .initialization(.createNewWallet))

            case .initialization(.configureCrashReporter):
                crashReporter.configure(
                    !userStoredPreferences.isUserOptedOutOfCrashReporting()
                )
                return .none
                
            case .updateStateAfterConfigUpdate(let walletConfig):
                state.walletConfig = walletConfig
                state.onboardingState.walletConfig = walletConfig
                state.homeState.walletConfig = walletConfig
                return .none

            case .initialization(.initializationFailed(let error)):
                state.appInitializationState = .failed
                state.alert = AlertState.initializationFailed(error)
                return .none

            case .home, .destination, .onboarding, .phraseDisplay, .phraseValidation, .sandbox,
                .welcome, .binding, .debug, .exportLogs, .alert:
                return .none
            }
        }
    }
}
