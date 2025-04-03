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
import Generated
import WalletStorage

/// In this file is a collection of helpers that control all state and action related operations
/// for the `Root` with a connection to the app/wallet initialization and erasure of the wallet.
extension Root {
    public enum Constants {
        static let udIsRestoringWallet = "udIsRestoringWallet"
        static let noAuthenticationWithinXMinutes = 15
    }
    
    public enum InitializationAction {
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
        case loadedWalletAccounts([WalletAccount])
        case resetZashi
        case resetZashiRequest
        case respondToWalletInitializationState(InitializationState)
        case restoreExistingWallet
        case seedValidationResult(Bool)
        case synchronizerStartFailed(ZcashError)
        case registerForSynchronizersUpdate
        case retryStart
        case walletConfigChanged(WalletConfig)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    public func initializationReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .initialization(.appDelegate(.didFinishLaunching)):
                state.appStartState = .didFinishLaunching
                // TODO: [#704], trigger the review request logic when approved by the team,
                // https://github.com/Electric-Coin-Company/zashi-ios/issues/704
                return .concatenate(
                    .send(.initialization(.configureCrashReporter)),
                    .run { send in
                        try await mainQueue.sleep(for: .seconds(0.5))
                        await send(.initialization(.initialSetups))
                    }
                    .cancellable(id: DidFinishLaunchingId, cancelInFlight: true)
                )

            case .initialization(.appDelegate(.willEnterForeground)):
                if state.featureFlags.appLaunchBiometric {
                    let now = Date()
                    let before = Date.init(timeIntervalSince1970: TimeInterval(state.lastAuthenticationTimestamp))
                    if let xMinutesAgo = Calendar.current.date(byAdding: .minute, value: -Constants.noAuthenticationWithinXMinutes, to: now),
                       before < xMinutesAgo {
                        state.splashAppeared = false
                    }
                }
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

                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                
                // update flexa balance
                if let accountBalance = latestState.data.accountsBalances[account.id] {
                    let shieldedBalance = accountBalance.saplingBalance.spendableValue + accountBalance.orchardBalance.spendableValue
                    let shieldedWithPendingBalance = accountBalance.saplingBalance.total() + accountBalance.orchardBalance.total()

                    flexaHandler.updateBalance(shieldedWithPendingBalance, shieldedBalance)
                }
                
                // handle possible service unavailability
                if case .error(let error) = snapshot.syncStatus, checkUnavailableService(error) {
                    if state.walletStatus != .disconnected {
                        state.alert = AlertState.serviceUnavailable()
                    }
                    state.wasRestoringWhenDisconnected = state.walletStatus == .restoring
                    state.$walletStatus.withLock { $0 = .disconnected }
                } else if case .syncing = snapshot.syncStatus, state.walletStatus == .disconnected {
                    state.$walletStatus.withLock { $0 = state.wasRestoringWhenDisconnected ? .restoring : .none }
                }

                // handle BCGTask
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
                    state.$walletStatus.withLock { $0 = .none }
                }
                return .none

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
                        .map(Root.Action.synchronizerStateChanged)
                }
                .cancellable(id: CancelStateId, cancelInFlight: true)

            case .initialization(.checkWalletConfig):
                return .publisher {
                    walletConfigProvider.load()
                        .receive(on: mainQueue)
                        .map(Root.Action.walletConfigLoaded)
                }
                .cancellable(id: WalletConfigCancelId, cancelInFlight: true)

            case .walletConfigLoaded(let walletConfig):
                if walletConfig == WalletConfig.initial {
                    return .send(.initialization(.initialSetups))
                } else {
                    return .send(.initialization(.walletConfigChanged(walletConfig)))
                }
                
            case .initialization(.walletConfigChanged(let walletConfig)):
                return .concatenate(
                    .send(.updateStateAfterConfigUpdate(walletConfig)),
                    .send(.initialization(.initialSetups))
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
                return .send(.initialization(.checkWalletInitialization))

                /// Evaluate the wallet's state based on keychain keys and database files presence
            case .initialization(.checkWalletInitialization):
                let walletState = Root.walletInitializationState(
                    databaseFiles: databaseFiles,
                    walletStorage: walletStorage,
                    zcashNetwork: zcashSDKEnvironment.network
                )
                return .send(.initialization(.respondToWalletInitializationState(walletState)))

                /// Respond to all possible states of the wallet and initiate appropriate side effects including errors handling
            case .initialization(.respondToWalletInitializationState(let walletState)):
                switch walletState {
                case .osStatus(let osStatus):
                    state.osStatusErrorState.osStatus = osStatus
                    return .send(.destination(.updateDestination(.osStatusError)))
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
                    state.$walletStatus.withLock { $0 = .restoring }
                    return .concatenate(
                        .send(.initialization(.initializeSDK(.restoreWallet))),
                        .send(.initialization(.checkBackupPhraseValidation))
                    )
                case .initialized:
                    if let isRestoringWallet = userDefaults.objectForKey(Constants.udIsRestoringWallet) as? Bool, isRestoringWallet {
                        state.isRestoringWallet = true
                        state.$walletStatus.withLock { $0 = .restoring }
                        return .concatenate(
                            .send(.initialization(.initializeSDK(.restoreWallet))),
                            .send(.initialization(.checkBackupPhraseValidation))
                        )
                    }
                    return .concatenate(
                        .send(.initialization(.initializeSDK(.existingWallet))),
                        .send(.initialization(.checkBackupPhraseValidation))
                    )
                case .uninitialized:
                    state.appInitializationState = .uninitialized
                    return .run { send in
                        try await mainQueue.sleep(for: .seconds(0.5))
                        await send(.destination(.updateDestination(.onboarding)))
                    }
                    .cancellable(id: CancelId, cancelInFlight: true)
                }
                
                /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
                /// When initialization succeeds user is taken to the home screen.
            case .initialization(.initializeSDK(let walletMode)):
                do {
                    let storedWallet: StoredWallet
                    do {
                        storedWallet = try walletStorage.exportWallet()
                    } catch {
                        return .send(.destination(.updateDestination(.osStatusError)))
                    }
                    let birthday = storedWallet.birthday?.value() ?? zcashSDKEnvironment.latestCheckpoint
                    try mnemonic.isValid(storedWallet.seedPhrase.value())
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())

                    return .run { send in
                        do {
                            try await sdkSynchronizer.prepareWith(
                                seedBytes,
                                birthday,
                                walletMode,
                                L10n.Accounts.zashi,
                                L10n.Accounts.zashi.lowercased()
                            )
                            
                            let walletAccounts = try await sdkSynchronizer.walletAccounts()
                            await send(.initialization(.loadedWalletAccounts(walletAccounts)))
                            await send(.resolveMetadataEncryptionKeys)

                            try await sdkSynchronizer.start(false)

                            var selectedAccount: WalletAccount?
                            
                            for account in walletAccounts {
                                if account.vendor == .zcash {
                                    selectedAccount = account
                                }
                            }

                            if let account = selectedAccount {
                                let addressBookEncryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys()
                                if addressBookEncryptionKeys == nil {
                                    do {
                                        var keys = AddressBookEncryptionKeys.empty
                                        try keys.cacheFor(
                                            seed: seedBytes,
                                            account: account.account,
                                            network: zcashSDKEnvironment.network.networkType
                                        )
                                        try walletStorage.importAddressBookEncryptionKeys(keys)
                                    } catch {
                                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                                    }
                                }

                                let uAddress = try? await sdkSynchronizer.getUnifiedAddress(account.id)
                                await send(.initialization(.initializationSuccessfullyDone(uAddress)))
                            } else {
                                await send(.initialization(.initializationSuccessfullyDone(nil)))
                            }
                        } catch {
                            await send(.initialization(.initializationFailed(error.toZcashError())))
                        }
                    }
                } catch {
                    return .send(.initialization(.initializationFailed(error.toZcashError())))
                }
                
            case .initialization(.initializationSuccessfullyDone(let uAddress)):
                state.zashiUAddress = uAddress
                state.homeState.uAddress = uAddress
                state.settingsState.uAddress = uAddress
                state.requestZecCoordFlowState.uAddress = uAddress
//                state.tabsState.settingsState.integrationsState.uAddress = uAddress
//                state.tabsState.uAddress = uAddress
//                if let uAddress = uAddress?.stringEncoded {
//                    state.tabsState.sendState.memoState.uAddress = uAddress
//                }
                return .merge(
                    .send(.initialization(.registerForSynchronizersUpdate)),
                    .publisher {
                        autolockHandler.batteryStatePublisher()
                            .map(Root.Action.batteryStateChanged)
                    }
                    .cancellable(id: CancelBatteryStateId, cancelInFlight: true),
                    .send(.batteryStateChanged(nil)),
                    .send(.observeTransactions)
                )
                
            case .initialization(.loadedWalletAccounts(let walletAccounts)):
                state.$walletAccounts.withLock { $0 = walletAccounts }
                if state.selectedWalletAccount == nil {
                    for account in walletAccounts {
                        if account.vendor == .zcash {
                            state.$selectedWalletAccount.withLock { $0 = account }
                            state.$zashiWalletAccount.withLock { $0 = account }
                            break
                        }
                    }
                }
                return .merge(
                    .send(.loadContacts),
                    .send(.loadUserMetadata)
                )

//            case .tabs(.addKeystoneHWWallet(.loadedWalletAccounts)), .tabs(.settings(.integrations(.addKeystoneHWWallet(.loadedWalletAccounts)))):
//                return .merge(
//                    .send(.resolveMetadataEncryptionKeys),
//                    .send(.loadUserMetadata)
//                )
                
            case .resolveMetadataEncryptionKeys:
                do {
                    let storedWallet: StoredWallet
                    do {
                        storedWallet = try walletStorage.exportWallet()
                    } catch {
                        return .send(.destination(.updateDestination(.osStatusError)))
                    }
                    try mnemonic.isValid(storedWallet.seedPhrase.value())
                    let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                    
                    return .run { [walletAccounts = state.walletAccounts] send in
                        do {
                            
                            for account in walletAccounts {
                                let userMetadataEncryptionKeys = try? walletStorage.exportUserMetadataEncryptionKeys(account.account)
                                if userMetadataEncryptionKeys == nil {
                                    do {
                                        var keys = UserMetadataEncryptionKeys.empty
                                        try keys.cacheFor(
                                            seed: seedBytes,
                                            account: account.account,
                                            network: zcashSDKEnvironment.network.networkType
                                        )
                                        try walletStorage.importUserMetadataEncryptionKeys(keys, account.account)
                                    } catch {
                                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                                    }
                                }
                            }
                        }
                    }
                } catch { }
                return .none
                
            case .initialization(.checkBackupPhraseValidation):
                let storedWallet: StoredWallet
                do {
                    storedWallet = try walletStorage.exportWallet()
                } catch {
                    return .send(.destination(.updateDestination(.osStatusError)))
                }
                var landingDestination = Root.DestinationState.Destination.home
                
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
                let isAtDeeplinkWarningScreen = state.destinationState.destination == .deeplinkWarning
                
                return .run { [landingDestination] send in
//                    if landingDestination == .home {
//                        await send(.tabs(.home(.transactionList(.onAppear))))
//                    }
                    try await mainQueue.sleep(for: .seconds(0.5))
                    if !isAtDeeplinkWarningScreen {
                        await send(.destination(.updateDestination(landingDestination)))
                    }
                }
                .cancellable(id: CancelId, cancelInFlight: true)
                
            case .initialization(.resetZashiRequest):
                state.alert = AlertState.wipeRequest()
                return .none
                
            case .initialization(.resetZashi):
                guard let wipePublisher = sdkSynchronizer.wipe() else {
                    return .send(.resetZashiSDKFailed)
                }
                return .publisher {
                    wipePublisher
                        .replaceEmpty(with: Void())
                        .map { _ in return Root.Action.resetZashiSDKSucceeded }
                        .replaceError(with: Root.Action.resetZashiSDKFailed)
                        .receive(on: mainQueue)
                }
                .cancellable(id: SynchronizerCancelId, cancelInFlight: true)

            case .resetZashiSDKSucceeded:
                if state.appInitializationState != .keysMissing {
                    state = .initial
                }
                state.splashAppeared = true
                state.isRestoringWallet = false
                userDefaults.remove(Constants.udIsRestoringWallet)
                flexaHandler.signOut()
                userStoredPreferences.removeAll()
                try? readTransactionsStorage.resetZashi()
                state.walletAccounts.forEach { account in
                    try? userMetadataProvider.resetAccount(account.account)
                }
                try? userMetadataProvider.reset()
                state.$walletStatus.withLock { $0 = .none }
                state.$selectedWalletAccount.withLock { $0 = nil }
                state.$walletAccounts.withLock { $0 = [] }
                state.$zashiWalletAccount.withLock { $0 = nil }
                state.$transactionMemos.withLock { $0 = [:] }
                state.$addressBookContacts.withLock { $0 = .empty }
                state.$transactions.withLock { $0 = [] }
                state.path = nil

                return .send(.resetZashiKeychainRequest)
                
            case .resetZashiKeychainRequest:
                return .run { send in
                    do {
                        try walletStorage.resetZashi()
                        await send(.resetZashiFinishProcessing)
                    } catch WalletStorage.KeychainError.unknown(let osStatus) {
                        await send(.resetZashiKeychainFailed(osStatus))
                    }
                }

            case .resetZashiFinishProcessing:
                do {
                    let areKeysPresent = try walletStorage.areKeysPresent()
                    if areKeysPresent {
                        return .send(.resetZashiKeychainFailedWithCorruptedData("Keychain keys are still present"))
                    }
                } catch WalletStorage.WalletStorageError.alreadyImported {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("alreadyImported"))
                } catch WalletStorage.WalletStorageError.uninitializedAddressBookEncryptionKeys {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("uninitializedAddressBookEncryptionKeys"))
                } catch WalletStorage.WalletStorageError.storageError(let error) {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("storageError, \(error.localizedDescription)"))
                } catch WalletStorage.WalletStorageError.unsupportedVersion(let version) {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("unsupportedVersion \(version)"))
                } catch WalletStorage.WalletStorageError.unsupportedLanguage(let language) {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("unsupportedLanguage, \(language)"))
                } catch WalletStorage.KeychainError.decoding {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("decoding"))
                } catch WalletStorage.KeychainError.duplicate {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("duplicate"))
                } catch WalletStorage.KeychainError.encoding {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("encoding"))
                } catch WalletStorage.KeychainError.noDataFound {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("noDataFound"))
                } catch WalletStorage.KeychainError.unknown(let osStatus) {
                    return .send(.resetZashiKeychainFailedWithCorruptedData("unknown, OSStatus \(osStatus)"))
                } catch WalletStorage.WalletStorageError.uninitializedWallet {
                    // this is valid state and what we expect
                } catch {
                    return .send(.resetZashiKeychainFailedWithCorruptedData(error.localizedDescription))
                }
                if state.appInitializationState == .keysMissing && state.onboardingState.destination == .importExistingWallet {
                    state.appInitializationState = .uninitialized
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .send(.onboarding(.importWallet(.updateDestination(.birthday))))
                    )
                } else if state.appInitializationState == .keysMissing && state.onboardingState.destination == .createNewWallet {
                    state.appInitializationState = .uninitialized
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .send(.onboarding(.securityWarning(.createNewWallet)))
                    )
                } else {
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .send(.initialization(.checkWalletInitialization))
                    )
                }
                
            case .resetZashiKeychainFailedWithCorruptedData(let errMsg):
                for element in state.settingsState.path {
                    if case .resetZashi(var resetZashiState) = element {
                        resetZashiState.isProcessing = false
                        break
                    }
                }
                state.alert = AlertState.wipeKeychainFailed(errMsg)
                return .cancel(id: SynchronizerCancelId)

            case .resetZashiKeychainFailed(let osStatus):
                guard state.maxResetZashiAppAttempts == 0 else {
                    state.maxResetZashiAppAttempts -= 1
                    return .send(.resetZashiKeychainRequest)
                }
                state.maxResetZashiAppAttempts = ResetZashiConstants.maxResetZashiAppAttempts
                for element in state.settingsState.path {
                    if case .resetZashi(var resetZashiState) = element {
                        resetZashiState.isProcessing = false
                        break
                    }
                }
                state.alert = AlertState.wipeFailed(osStatus)
                return .cancel(id: SynchronizerCancelId)

            case .resetZashiSDKFailed:
                guard state.maxResetZashiSDKAttempts == 0 else {
                    state.maxResetZashiSDKAttempts -= 1
                    return .concatenate(
                        .cancel(id: SynchronizerCancelId),
                        .send(.initialization(.resetZashi))
                    )
                }
                state.maxResetZashiSDKAttempts = ResetZashiConstants.maxResetZashiSDKAttempts
                for element in state.settingsState.path {
                    if case .resetZashi(var resetZashiState) = element {
                        resetZashiState.isProcessing = false
                        break
                    }
                }
                state.alert = AlertState.wipeFailed(Int32.max)
                return .cancel(id: SynchronizerCancelId)

            case .phraseDisplay(.finishedTapped), .onboarding(.securityWarning(.recoveryPhraseDisplay(.finishedTapped))):
                do {
                    try walletStorage.markUserPassedPhraseBackupTest(true)
                    state.destinationState.destination = .home
                } catch {
                    state.alert = AlertState.cantStoreThatUserPassedPhraseBackupTest(error.toZcashError())
                }
                return .none
                
            case .welcome(.debugMenuStartup)://, .tabs(.home(.walletBalances(.debugMenuStartup))):
                return .concatenate(
                    Effect.cancel(id: CancelId),
                    .send(.destination(.updateDestination(.startup)))
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
                
            case .onboarding(.importWallet(.nextTapped)):
                if state.appInitializationState == .keysMissing {
                    let seedPhrase = state.onboardingState.importWalletState.importedSeedPhrase
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

            case .onboarding(.importWallet(.restoreInfo(.gotItTapped))):
                state.destinationState.destination = .home
                return .none

            case .onboarding(.importWallet(.initializeSDK)):
                state.isRestoringWallet = true
                userDefaults.setValue(true, Constants.udIsRestoringWallet)
                state.$walletStatus.withLock { $0 = .restoring }
                return .concatenate(
                    .send(.initialization(.initializeSDK(.restoreWallet))),
                    .send(.initialization(.checkBackupPhraseValidation))
                )

            case .initialization(.seedValidationResult(let validSeed)):
                if validSeed {
                    state.onboardingState.importWalletState.destination = .birthday
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
//                state.tabsState.homeState.walletConfig = walletConfig
                return .none

            case .initialization(.initializationFailed(let error)):
                state.appInitializationState = .failed
                state.alert = AlertState.initializationFailed(error)
                return .none

            case .onboarding(.securityWarning(.newWalletCreated)):
                return .send(.initialization(.initializeSDK(.newWallet)))
                
            default:
                return .none
            }
        }
    }
    
    private func checkUnavailableService(_ error: Error) -> Bool {
        switch error {
        case ZcashError.serviceGetInfoFailed(.timeOut),
            ZcashError.serviceLatestBlockFailed(.timeOut),
            ZcashError.serviceLatestBlockHeightFailed(.timeOut),
            ZcashError.serviceBlockRangeFailed(.timeOut),
            ZcashError.serviceSubmitFailed(.timeOut),
            ZcashError.serviceFetchTransactionFailed(.timeOut),
            ZcashError.serviceFetchUTXOsFailed(.timeOut),
            ZcashError.serviceBlockStreamFailed(.timeOut),
            ZcashError.serviceSubtreeRootsStreamFailed(.timeOut):
            return true
        default: return false
        }
    }
}
