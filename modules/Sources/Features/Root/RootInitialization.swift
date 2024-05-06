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
import NotEnoughFreeSpace
import Utils

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the app/wallet initialization and erasure of the wallet.
extension RootReducer {
    public enum Constants {
        static let udIsRestoringWallet = "udIsRestoringWallet"
    }
    
    public enum InitializationAction: Equatable {
        case appDelegate(AppDelegateAction)
        case checkBackupPhraseValidation
        case checkRestoreWalletFlag(SyncStatus)
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
        case restoreExistingWallet
        case seedValidationResult(Bool)
        case synchronizerStartFailed(ZcashError)
        case registerForSynchronizersUpdate
        case retryStart
        case walletConfigChanged(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func initializationReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case .initialization(.appDelegate(.didFinishLaunching)):
                state.appStartState = .didFinishLaunching
                hideBalances.prepare()
                // TODO: [#704], trigger the review request logic when approved by the team,
                // https://github.com/Electric-Coin-Company/zashi-ios/issues/704
                return .concatenate(
                    Effect.send(.initialization(.configureCrashReporter)),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(0.5))
                        await send(.initialization(.initialSetups))
                    }
                    .cancellable(id: DidFinishLaunchingId, cancelInFlight: true)
                )

            case .initialization(.appDelegate(.willEnterForeground)):
                state.appStartState = .willEnterForeground
                if state.isLockedInKeychainUnavailableState || !sdkSynchronizer.latestState().syncStatus.isPrepared {
                    return .send(.initialization(.initialSetups))
                } else {
                    return .send(.initialization(.retryStart))
                }
                
            case .initialization(.appDelegate(.didEnterBackground)):
                sdkSynchronizer.stop()
                state.bgTask?.setTaskCompleted(success: false)
                state.bgTask = nil
                state.appStartState = .didEnterBackground
                state.isLockedInKeychainUnavailableState = false
                return .cancel(id: CancelStateId)
                
            case .initialization(.appDelegate(.backgroundTask(let task))):
                let keysPresent: Bool = (try? walletStorage.areKeysPresent()) ?? false
                if state.appStartState == .didFinishLaunching {
                    state.appStartState = .backgroundTask
                    if keysPresent {
                        state.bgTask = task
                        return .none
                    } else {
                        state.isLockedInKeychainUnavailableState = true
                        task.setTaskCompleted(success: false)
                        return .cancel(id: DidFinishLaunchingId)
                    }
                } else {
                    state.bgTask = task
                    state.appStartState = .backgroundTask
                    return .run { send in
                        await send(.initialization(.retryStart))
                    }
                }
                
            case .synchronizerStateChanged(let latestState):
                let snapshot = SyncStatusSnapshot.snapshotFor(state: latestState.data.syncStatus)
                
                guard state.bgTask != nil else {
                    return .send(.initialization(.checkRestoreWalletFlag(snapshot.syncStatus)))
                }
                
                var finishBGTask = false
                var successOfBGTask = false
                
                switch snapshot.syncStatus {
                case .upToDate:
                    successOfBGTask = true
                    finishBGTask = true
                case .stopped, .error:
                    successOfBGTask = false
                    finishBGTask = true
                default: break
                }
                
                if finishBGTask  {
                    LoggerProxy.event("BGTask setTaskCompleted(success: \(successOfBGTask)) from TCA")
                    state.bgTask?.setTaskCompleted(success: successOfBGTask)
                    state.bgTask = nil
                    return .cancel(id: CancelStateId)
                }
                
                return .send(.initialization(.checkRestoreWalletFlag(snapshot.syncStatus)))
                
            case .initialization(.checkRestoreWalletFlag(let syncStatus)):
                if state.isRestoringWallet && syncStatus == .upToDate {
                    state.isRestoringWallet = false
                    userDefaults.remove(Constants.udIsRestoringWallet)
                    return .run { _ in
                        await restoreWalletStorage.updateValue(false)
                    }
                } else {
                    return .none
                }
                
            case .initialization(.synchronizerStartFailed):
                return .none
                
            case .initialization(.retryStart):
                if !diskSpaceChecker.hasEnoughFreeSpaceForSync() {
                    state.destinationState.preNotEnoughFreeSpaceDestination = state.destinationState.internalDestination
                    return .send(.destination(.updateDestination(.notEnoughFreeSpace)))
                } else if let preNotEnoughFreeSpaceDestination = state.destinationState.preNotEnoughFreeSpaceDestination {
                    state.destinationState.internalDestination = preNotEnoughFreeSpaceDestination
                    state.destinationState.preNotEnoughFreeSpaceDestination = nil
                }
                // Try the start only if the synchronizer has been already prepared
                guard sdkSynchronizer.latestState().syncStatus.isPrepared else {
                    return .none
                }
                return .run { [state] send in
                    do {
                        try await sdkSynchronizer.start(true)
                        if state.bgTask != nil {
                            LoggerProxy.event("BGTask synchronizer.start() PASSED")
                        }
                        await send(.initialization(.registerForSynchronizersUpdate))
                    } catch {
                        if state.bgTask != nil {
                            LoggerProxy.event("BGTask synchronizer.start() failed \(error.toZcashError())")
                        }
                        await send(.initialization(.synchronizerStartFailed(error.toZcashError())))
                    }
                }
                
            case .initialization(.registerForSynchronizersUpdate):
                return .publisher {
                    sdkSynchronizer.stateStream()
                        .throttle(for: .seconds(0.2), scheduler: mainQueue, latest: true)
                        .map { $0.redacted }
                        .map(RootReducer.Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelStateId, cancelInFlight: true)

            case .initialization(.checkWalletConfig):
                return .publisher {
                    walletConfigProvider.load()
                        .receive(on: mainQueue)
                        .map(RootReducer.Action.walletConfigLoaded)
                }
                .cancellable(id: WalletConfigCancelId, cancelInFlight: true)

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
                if !diskSpaceChecker.hasEnoughFreeSpaceForSync() {
                    state.destinationState.preNotEnoughFreeSpaceDestination = state.destinationState.internalDestination
                    return .send(.destination(.updateDestination(.notEnoughFreeSpace)))
                } else if let preNotEnoughFreeSpaceDestination = state.destinationState.preNotEnoughFreeSpaceDestination {
                    state.destinationState.internalDestination = preNotEnoughFreeSpaceDestination
                    state.destinationState.preNotEnoughFreeSpaceDestination = nil
                }
                // TODO: [#524] finish all the wallet events according to definition, https://github.com/Electric-Coin-Company/zashi-ios/issues/524
                LoggerProxy.event(".appDelegate(.didFinishLaunching)")
                /// We need to fetch data from keychain, in order to be 100% sure the keychain can be read we delay the check a bit
                return Effect.send(.initialization(.checkWalletInitialization))

                /// Evaluate the wallet's state based on keychain keys and database files presence
            case .initialization(.checkWalletInitialization):
                let walletState = RootReducer.walletInitializationState(
                    databaseFiles: databaseFiles,
                    walletStorage: walletStorage,
                    zcashNetwork: zcashSDKEnvironment.network
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
                    return .send(.destination(.updateDestination(.onboarding)))
                case .filesMissing:
                    state.appInitializationState = .filesMissing
                    state.isRestoringWallet = true
                    userDefaults.setValue(true, Constants.udIsRestoringWallet)
                    return .concatenate(
                        .merge(
                            Effect.send(.initialization(.initializeSDK(.restoreWallet))),
                            .run { _ in
                                await restoreWalletStorage.updateValue(true)
                            }
                        ),
                        Effect.send(.initialization(.checkBackupPhraseValidation))
                    )
                case .initialized:
                    if let isRestoringWallet = userDefaults.objectForKey(Constants.udIsRestoringWallet) as? Bool, isRestoringWallet {
                        state.isRestoringWallet = true
                        return .concatenate(
                            .merge(
                                Effect.send(.initialization(.initializeSDK(.restoreWallet))),
                                .run { _ in
                                    await restoreWalletStorage.updateValue(true)
                                }
                            ),
                            Effect.send(.initialization(.checkBackupPhraseValidation))
                        )
                    }
                    return .concatenate(
                        Effect.send(.initialization(.initializeSDK(.existingWallet))),
                        Effect.send(.initialization(.checkBackupPhraseValidation))
                    )
                case .uninitialized:
                    state.appInitializationState = .uninitialized
                    return .run { send in
                        try await mainQueue.sleep(for: .seconds(2.5))
                        await send(.destination(.updateDestination(.onboarding)))
                    }
                    .cancellable(id: CancelId, cancelInFlight: true)
                }
                
                /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
                /// When initialization succeeds user is taken to the home screen.
            case .initialization(.initializeSDK(let walletMode)):
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let birthday = storedWallet.birthday?.value() ?? zcashSDKEnvironment.latestCheckpoint
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
                return .send(.initialization(.registerForSynchronizersUpdate))
                
            case .initialization(.checkBackupPhraseValidation):
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    var landingDestination = RootReducer.DestinationState.Destination.tabs

                    if !storedWallet.hasUserPassedPhraseBackupTest {
                        let phraseWords = mnemonic.asWords(storedWallet.seedPhrase.value())
                        
                        let recoveryPhrase = RecoveryPhrase(words: phraseWords.map { $0.redacted })
                        state.phraseDisplayState.phrase = recoveryPhrase
                        state.phraseDisplayState.birthday = storedWallet.birthday
                        if let value = storedWallet.birthday?.value() {
                            let latestBlock = numberFormatter.string(NSDecimalNumber(value: value))
                            state.phraseDisplayState.birthdayValue = "\(String(describing: latestBlock ?? ""))"
                        }
                        landingDestination = .phraseDisplay
                    }
                    
                    state.appInitializationState = .initialized
                    
                    return .run { [landingDestination] send in
                        try await mainQueue.sleep(for: .seconds(2.5))
                        await send(.destination(.updateDestination(landingDestination)))
                    }
                    .cancellable(id: CancelId, cancelInFlight: true)
                } catch {
                    return Effect.send(.initialization(.initializationFailed(error.toZcashError())))
                }

            case .initialization(.nukeWalletRequest):
                state.alert = AlertState.wipeRequest()
                return .none
                
            case .initialization(.nukeWallet), .tabs(.settings(.advancedSettings(.deleteWallet(.deleteTapped)))):
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
                .cancellable(id: SynchronizerCancelId, cancelInFlight: true)

            case .nukeWalletSucceeded:
                if state.appInitializationState != .keysMissing {
                    state = .initial
                }
                state.splashAppeared = true
                walletStorage.nukeWallet()
                try? readTransactionsStorage.nukeWallet()

                if state.appInitializationState == .keysMissing && state.onboardingState.destination == .importExistingWallet {
                    state.appInitializationState = .uninitialized
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .run { send in
                            await userStoredPreferences.removeAll()
                        },
                        Effect.send(.onboarding(.importWallet(.updateDestination(.birthday))))
                    )
                } else if state.appInitializationState == .keysMissing && state.onboardingState.destination == .createNewWallet {
                    state.appInitializationState = .uninitialized
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .run { send in
                            await userStoredPreferences.removeAll()
                        },
                        Effect.send(.onboarding(.securityWarning(.createNewWallet)))
                    )
                } else {
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .run { send in
                            await userStoredPreferences.removeAll()
                        },
                        Effect.send(.initialization(.checkWalletInitialization))
                    )
                }

            case .nukeWalletFailed:
                let backDestination: Effect<RootReducer.Action>
                if let previousDestination = state.destinationState.previousDestination {
                    backDestination = Effect.send(.destination(.updateDestination(previousDestination)))
                } else {
                    backDestination = Effect.send(.destination(.updateDestination(state.destinationState.destination)))
                }
                state.alert = AlertState.wipeFailed()

                if state.appInitializationState == .keysMissing {
                    return .cancel(id: SynchronizerCancelId)
                } else {
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        backDestination
                    )
                }

            case .phraseDisplay(.finishedPressed), .onboarding(.securityWarning(.recoveryPhraseDisplay(.finishedPressed))):
                do {
                    try walletStorage.markUserPassedPhraseBackupTest(true)
                    state.destinationState.destination = .tabs
                } catch {
                    state.alert = AlertState.cantStoreThatUserPassedPhraseBackupTest(error.toZcashError())
                }
                return .none
                
            case .welcome(.debugMenuStartup), .tabs(.home(.walletBalances(.debugMenuStartup))):
                return .concatenate(
                    Effect.cancel(id: CancelId),
                    Effect.send(.destination(.updateDestination(.startup)))
                )

            case .onboarding(.securityWarning(.confirmTapped)):
                if state.appInitializationState == .keysMissing {
                    state.alert = AlertState.existingWallet()
                    return .none
                } else {
                    return .send(.onboarding(.securityWarning(.createNewWallet)))
                }
                
            case .initialization(.restoreExistingWallet):
                return .run { send in
                    await send(.onboarding(.updateDestination(nil)))
                    try await mainQueue.sleep(for: .seconds(1))
                    await send(.onboarding(.importExistingWallet))
                }
                
            case .onboarding(.importWallet(.nextPressed)):
                if state.appInitializationState == .keysMissing {
                    let seedPhrase = state.onboardingState.importWalletState.importedSeedPhrase.data
                    return .run { send in
                        do {
                            let seedBytes = try mnemonic.toSeed(seedPhrase)
                            let result = try await sdkSynchronizer.isSeedRelevantToAnyDerivedAccount(seedBytes)
                            await send(.initialization(.seedValidationResult(result)))
                        } catch {
                            await send(.initialization(.seedValidationResult(false)))
                        }
                    }
                } else {
                    state.onboardingState.importWalletState.destination = .birthday
                    return .none
                }

            case .onboarding(.importWallet(.successfullyRecovered)):
                state.alert = AlertState.successfullyRecovered()
                return Effect.send(.destination(.updateDestination(.tabs)))

            case .onboarding(.importWallet(.initializeSDK)):
                state.isRestoringWallet = true
                userDefaults.setValue(true, Constants.udIsRestoringWallet)
                return .merge(
                    Effect.send(.initialization(.initializeSDK(.restoreWallet))),
                    .run { _ in
                        await restoreWalletStorage.updateValue(true)
                    }
                )

            case .initialization(.seedValidationResult(let validSeed)):
                if validSeed {
                    return .send(.onboarding(.importWallet(.restoreWallet)))
                } else {
                    state.alert = AlertState.differentSeed()
                }
                return .none
                
            case .initialization(.configureCrashReporter):
                crashReporter.configure(true)
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
                
            case .tabs, .destination, .onboarding, .sandbox, .phraseDisplay, .notEnoughFreeSpace,
                    .welcome, .binding, .debug, .exportLogs, .alert, .splashFinished, .splashRemovalRequested, .confirmationDialog:
                return .none
            }
        }
    }
}
