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
        case checkWalletConfig
        case initializeSDK(WalletInitMode)
        case initialSetups
        case initializationFailed(ZcashError)
        case initializationSuccessfullyDone(UnifiedAddress?)
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
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(1))
                    await send(.initialization(.retryStart))
                }
                
            case .initialization(.synchronizerStartFailed):
                return .none

            case .initialization(.retryStart):
                // Try the start only if the synchronizer has been already prepared
                guard sdkSynchronizer.latestState().syncStatus.isPrepared else {
                    return .none
                }
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
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(0.02))
                    await send(.initialization(.initialSetups))
                }

            case .initialization(.checkWalletConfig):
                return .publisher {
                    walletConfigProvider.load()
                        .receive(on: mainQueue)
                        .map(RootReducer.Action.walletConfigLoaded)
                }
                .cancellable(id: WalletConfigCancelId.timer, cancelInFlight: true)

            case .walletConfigLoaded(let walletConfig):
                if walletConfig == WalletConfig.initial {
                    return Effect.send(.initialization(.initialSetups))
                } else {
                    return Effect.send(.initialization(.walletConfigChanged(walletConfig)))
                }
            
            case .initialization(.walletConfigChanged(let walletConfig)):
                return .concatenate(
                    Effect.send(.updateStateAfterConfigUpdate(walletConfig)),
                    Effect.send(.initialization(.initialSetups))
                )
                
            case .initialization(.initialSetups):
                // TODO: [#524] finish all the wallet events according to definition, https://github.com/zcash/secant-ios-wallet/issues/524
                LoggerProxy.event(".appDelegate(.didFinishLaunching)")
                /// We need to fetch data from keychain, in order to be 100% sure the keychain can be read we delay the check a bit
                return .concatenate(
                    Effect.send(.initialization(.configureCrashReporter)),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(0.02))
                        await send(.initialization(.checkWalletInitialization))
                    }
                )

                /// Evaluate the wallet's state based on keychain keys and database files presence
            case .initialization(.checkWalletInitialization):
                let walletState = RootReducer.walletInitializationState(
                    databaseFiles: databaseFiles,
                    walletStorage: walletStorage,
                    zcashNetwork: zcashNetwork
                )
                return Effect.send(.initialization(.respondToWalletInitializationState(walletState)))

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
                        Effect.send(.initialization(.initializeSDK(.existingWallet))),
                        Effect.send(.initialization(.checkBackupPhraseValidation))
                    )
                case .uninitialized:
                    state.appInitializationState = .uninitialized
                    return .run { send in
                        try await mainQueue.sleep(for: .seconds(3))
                        await send(.destination(.updateDestination(.onboarding)))
                    }
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

                            let uAddress = try? await sdkSynchronizer.getUnifiedAddress(0)
                            await send(.initialization(.initializationSuccessfullyDone(uAddress)))
                        } catch {
                            await send(.initialization(.initializationFailed(error.toZcashError())))
                        }
                    }
                } catch {
                    return Effect.send(.initialization(.initializationFailed(error.toZcashError())))
                }

            case .initialization(.initializationSuccessfullyDone(let uAddress)):
                state.tabsState.addressDetailsState.uAddress = uAddress
                return .none

            case .initialization(.checkBackupPhraseValidation):
                guard let storedWallet = state.storedWallet else {
                    state.appInitializationState = .failed
                    state.alert = AlertState.cantLoadSeedPhrase()
                    return .none
                }

                state.appInitializationState = .initialized

                return .run { send in
                    try await mainQueue.sleep(for: .seconds(3))
                    await send(.destination(.updateDestination(.tabs)))
                }
                .cancellable(id: CancelId.timer, cancelInFlight: true)

            case .initialization(.nukeWalletRequest):
                state.alert = AlertState.wipeRequest()
                return .none
            
            case .initialization(.nukeWallet):
                guard let wipePublisher = sdkSynchronizer.wipe() else {
                    return Effect.send(.nukeWalletFailed)
                }
                return .publisher {
                    wipePublisher
                        .replaceEmpty(with: Void())
                        .map { _ in return RootReducer.Action.nukeWalletSucceeded }
                        .replaceError(with: RootReducer.Action.nukeWalletFailed)
                        .receive(on: mainQueue)
                }
                .cancellable(id: SynchronizerCancelId.timer, cancelInFlight: true)

            case .nukeWalletSucceeded:
                state = .initial
                state.splashAppeared = true
                walletStorage.nukeWallet()
                try? readTransactionsStorage.nukeWallet()
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.timer),
                    .run { send in
                        await userStoredPreferences.removeAll()
                    },
                    Effect.send(.initialization(.checkWalletInitialization))
                )

            case .nukeWalletFailed:
                let backDestination: Effect<RootReducer.Action>
                if let previousDestination = state.destinationState.previousDestination {
                    backDestination = Effect.send(.destination(.updateDestination(previousDestination)))
                } else {
                    backDestination = Effect.send(.destination(.updateDestination(state.destinationState.destination)))
                }
                state.alert = AlertState.wipeFailed()
                return .concatenate(
                    .cancel(id: SynchronizerCancelId.timer),
                    backDestination
                )

            case .welcome(.debugMenuStartup), .tabs(.home(.debugMenuStartup)):
                return .concatenate(
                    Effect.cancel(id: CancelId.timer),
                    Effect.send(.destination(.updateDestination(.startup)))
                )

            case .onboarding(.importWallet(.successfullyRecovered)):
                state.alert = AlertState.successfullyRecovered()
                return Effect.send(.destination(.updateDestination(.tabs)))

            case .onboarding(.importWallet(.initializeSDK)):
                return Effect.send(.initialization(.initializeSDK(.restoreWallet)))

            case .initialization(.configureCrashReporter):
                crashReporter.configure(
                    !userStoredPreferences.isUserOptedOutOfCrashReporting()
                )
                return .none
                
            case .updateStateAfterConfigUpdate(let walletConfig):
                state.walletConfig = walletConfig
                state.onboardingState.walletConfig = walletConfig
                state.tabsState.homeState.walletConfig = walletConfig
                return .none

            case .initialization(.initializationFailed(let error)):
                state.appInitializationState = .failed
                state.alert = AlertState.initializationFailed(error)
                return .none

            case .onboarding(.securityWarning(.newWalletCreated)):
                return Effect.send(.initialization(.initializeSDK(.newWallet)))

            case .onboarding(.securityWarning(.recoveryPhraseDisplay(.finishedPressed))):
                return Effect.send(.destination(.updateDestination(.tabs)))
                
            case .tabs, .destination, .onboarding, .sandbox,
            .welcome, .binding, .debug, .exportLogs, .alert, .splashFinished, .splashRemovalRequested:
                return .none
            }
        }
    }
}
