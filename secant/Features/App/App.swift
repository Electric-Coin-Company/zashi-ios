import ComposableArchitecture
import ZcashLightClientKit

struct AppState: Equatable {
    enum Route: Equatable {
        case welcome
        case startup
        case onboarding
        case sandbox
        case home
        case phraseValidation
        case phraseDisplay
    }
    
    var appInitializationState: InitializationState = .uninitialized
    var homeState: HomeState
    var onboardingState: OnboardingState
    var phraseValidationState: RecoveryPhraseValidationState
    var phraseDisplayState: RecoveryPhraseDisplayState
    var route: Route = .welcome
    var sandboxState: SandboxState
    var storedWallet: StoredWallet?
    var welcomeState: WelcomeState
}

enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case checkBackupPhraseValidation
    case checkWalletInitialization
    case createNewWallet
    case home(HomeAction)
    case initializeSDK
    case nukeWallet
    case onboarding(OnboardingAction)
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case phraseValidation(RecoveryPhraseValidationAction)
    case respondToWalletInitializationState(InitializationState)
    case sandbox(SandboxAction)
    case updateRoute(AppState.Route)
    case welcome(WelcomeAction)
}

struct AppEnvironment {
    let wrappedSDKSynchronizer: WrappedSDKSynchronizer
    let databaseFiles: DatabaseFilesInteractor
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let scheduler: AnySchedulerOf<DispatchQueue>
    let walletStorage: WalletStorageInteractor
    let wrappedDerivationTool: WrappedDerivationTool
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension AppEnvironment {
    static let live = AppEnvironment(
        wrappedSDKSynchronizer: MockWrappedSDKSynchronizer(),
        databaseFiles: .live(),
        mnemonicSeedPhraseProvider: .live,
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        walletStorage: .live(),
        wrappedDerivationTool: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let mock = AppEnvironment(
        wrappedSDKSynchronizer: LiveWrappedSDKSynchronizer(),
        databaseFiles: .live(),
        mnemonicSeedPhraseProvider: .mock,
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        walletStorage: .live(),
        wrappedDerivationTool: .live(derivationTool: DerivationTool(networkType: .mainnet)),
        zcashSDKEnvironment: .mainnet
    )
}

// MARK: - AppReducer

private struct ListenerId: Hashable {}

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

extension AppReducer {
    static let `default` = AppReducer.combine(
        [
            appReducer,
            homeReducer,
            onboardingReducer,
            phraseValidationReducer,
            phraseDisplayReducer,
            routeReducer,
            sandboxReducer
        ]
    )
    .debug()

    private static let appReducer = AppReducer { state, action, environment in
        switch action {
        case .appDelegate(.didFinishLaunching):
            /// We need to fetch data from keychain, in order to be 100% sure the kecyhain can be read we delay the check a bit
            return Effect(value: .checkWalletInitialization)
                .delay(for: 0.02, scheduler: environment.scheduler)
                .eraseToEffect()
            
            /// Evaluate the wallet's state based on keychain keys and database files presence
        case .checkWalletInitialization:
            let walletState = walletInitializationState(environment)
            return Effect(value: .respondToWalletInitializationState(walletState))
            
            /// Respond to all possible states of the wallet and initiate appropriate side effects including errors handling
        case .respondToWalletInitializationState(let walletState):
            switch walletState {
            case .failed:
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.appInitializationState = .failed
            case .keysMissing:
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.appInitializationState = .keysMissing
            case .initialized, .filesMissing:
                if walletState == .filesMissing {
                    state.appInitializationState = .filesMissing
                }
                return .concatenate(
                    Effect(value: .initializeSDK),
                    Effect(value: .checkBackupPhraseValidation)
                )
            case .uninitialized:
                state.appInitializationState = .uninitialized
                return Effect(value: .updateRoute(.onboarding))
                    .delay(for: 3, scheduler: environment.scheduler)
                    .eraseToEffect()
                    .cancellable(id: ListenerId(), cancelInFlight: true)
            }
            
            return .none

            /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
            /// When initialization succeeds user is taken to the home screen.
        case .initializeSDK:
            do {
                state.storedWallet = try environment.walletStorage.exportWallet()
                
                guard let storedWallet = state.storedWallet else {
                    state.appInitializationState = .failed
                    // TODO: fatal error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                    return .none
                }
                
                try environment.mnemonicSeedPhraseProvider.isValid(storedWallet.seedPhrase)
                
                let birthday = state.storedWallet?.birthday ?? environment.zcashSDKEnvironment.defaultBirthday
                
                let initializer = try prepareInitializer(
                    for: storedWallet.seedPhrase,
                    birthday: birthday,
                    with: environment
                )
                try environment.wrappedSDKSynchronizer.prepareWith(initializer: initializer)
                try environment.wrappedSDKSynchronizer.start()
            } catch {
                state.appInitializationState = .failed
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
            }
            return .none

        case .checkBackupPhraseValidation:
            guard let storedWallet = state.storedWallet else {
                state.appInitializationState = .failed
                // TODO: fatal error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
            }

            var landingRoute: AppState.Route = .home
            
            if !storedWallet.hasUserPassedPhraseBackupTest {
                do {
                    let phraseWords = try environment.mnemonicSeedPhraseProvider.asWords(storedWallet.seedPhrase)
                    
                    let recoveryPhrase = RecoveryPhrase(words: phraseWords)
                    state.phraseDisplayState.phrase = recoveryPhrase
                    state.phraseValidationState = RecoveryPhraseValidationState.random(phrase: recoveryPhrase)
                    landingRoute = .phraseDisplay
                } catch {
                    // TODO: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                    return .none
                }
            }
            
            state.appInitializationState = .initialized
            return Effect(value: .updateRoute(landingRoute))
                .delay(for: 3, scheduler: environment.scheduler)
                .eraseToEffect()
                .cancellable(id: ListenerId(), cancelInFlight: true)
            
        case .createNewWallet:
            do {
                // get the random english mnemonic
                let randomPhrase = try environment.mnemonicSeedPhraseProvider.randomMnemonic()
                let birthday = try environment.zcashSDKEnvironment.lightWalletService.latestBlockHeight()
                
                // store the wallet to the keychain
                try environment.walletStorage.importWallet(randomPhrase, birthday, .english, false)
                
                // start the backup phrase validation test
                let randomPhraseWords = try environment.mnemonicSeedPhraseProvider.asWords(randomPhrase)
                let recoveryPhrase = RecoveryPhrase(words: randomPhraseWords)
                state.phraseDisplayState.phrase = recoveryPhrase
                state.phraseValidationState = RecoveryPhraseValidationState.random(phrase: recoveryPhrase)
                
                return .concatenate(
                    Effect(value: .initializeSDK),
                    Effect(value: .phraseValidation(.displayBackedUpPhrase))
                )
            } catch {
                // TODO: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
            }

            return .none

        case .phraseValidation(.succeed):
            do {
                try environment.walletStorage.markUserPassedPhraseBackupTest()
            } catch {
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
            }
            return .none

        case .nukeWallet:
            environment.walletStorage.nukeWallet()
            do {
                try environment.databaseFiles.nukeDbFilesFor(environment.zcashSDKEnvironment.network)
            } catch {
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
            }
            return .none

        case .welcome(.debugMenuStartup), .home(.debugMenuStartup):
            return .concatenate(
                Effect.cancel(id: ListenerId()),
                Effect(value: .updateRoute(.startup))
            )

        case .onboarding(.importWallet(.successfullyRecovered)):
            return Effect(value: .updateRoute(.home))

        case .onboarding(.importWallet(.initializeSDK)):
            return Effect(value: .initializeSDK)

            /// Default is meaningful here because there's `routeReducer` handling routes and this reducer is handling only actions. We don't here plenty of unused cases.
        default:
            return .none
        }
    }

    private static let routeReducer = AppReducer { state, action, environment in
        switch action {
        case let .updateRoute(route):
            state.route = route

        case .sandbox(.reset):
            state.route = .startup

        case .onboarding(.createNewWallet):
            return Effect(value: .createNewWallet)

        case .phraseValidation(.proceedToHome):
            state.route = .home

        case .phraseValidation(.displayBackedUpPhrase),
            .phraseDisplay(.createPhrase):
            state.route = .phraseDisplay

        case .phraseDisplay(.finishedPressed):
            // TODO: Advanced Routing: setting a route may vary depending on the originating context #285
            // see https://github.com/zcash/secant-ios-wallet/issues/285
            if let storedWallet = try? environment.walletStorage.exportWallet(),
                storedWallet.hasUserPassedPhraseBackupTest {
                state.route = .home
            } else {
                state.route = .phraseValidation
            }

            /// Default is meaningful here because there's `appReducer` handling actions and this reducer is handling only routes. We don't here plenty of unused cases.
        default:
            break
        }

        return .none
    }

    private static let homeReducer: AppReducer = HomeReducer.default.pullback(
        state: \AppState.homeState,
        action: /AppAction.home,
        environment: { environment in
            HomeEnvironment(
                scheduler: environment.scheduler,
                wrappedSDKSynchronizer: environment.wrappedSDKSynchronizer
            )
        }
    )

    private static let onboardingReducer: AppReducer = OnboardingReducer.default.pullback(
        state: \AppState.onboardingState,
        action: /AppAction.onboarding,
        environment: { environment in
            OnboardingEnvironment(
                mnemonicSeedPhraseProvider: environment.mnemonicSeedPhraseProvider,
                walletStorage: environment.walletStorage,
                zcashSDKEnvironment: environment.zcashSDKEnvironment
            )
        }
    )

    private static let phraseValidationReducer: AppReducer = RecoveryPhraseValidationReducer.default.pullback(
        state: \AppState.phraseValidationState,
        action: /AppAction.phraseValidation,
        environment: { _ in BackupPhraseEnvironment.demo }
    )

    private static let phraseDisplayReducer: AppReducer = RecoveryPhraseDisplayReducer.default.pullback(
        state: \AppState.phraseDisplayState,
        action: /AppAction.phraseDisplay,
        environment: { _ in BackupPhraseEnvironment.demo }
    )
    
    private static let sandboxReducer: AppReducer = SandboxReducer.default.pullback(
        state: \AppState.sandboxState,
        action: /AppAction.sandbox,
        environment: { _ in }
    )

    private static let welcomeReducer: AppReducer = WelcomeReducer.default.pullback(
        state: \AppState.welcomeState,
        action: /AppAction.welcome,
        environment: { _ in }
    )
}

// MARK: - AppReducer Helper Functions

extension AppReducer {
    static func walletInitializationState(_ environment: AppEnvironment) -> InitializationState {
        var keysPresent = false
        do {
            keysPresent = try environment.walletStorage.areKeysPresent()
            let databaseFilesPresent = try environment.databaseFiles.areDbFilesPresentFor(
                environment.zcashSDKEnvironment.network
            )
            
            switch (keysPresent, databaseFilesPresent) {
            case (false, false):
                return .uninitialized
            case (false, true):
                return .keysMissing
            case (true, false):
                return .filesMissing
            case (true, true):
                return .initialized
            }
        } catch DatabaseFiles.DatabaseFilesError.filesPresentCheck {
            if keysPresent {
                return .filesMissing
            }
        } catch WalletStorage.WalletStorageError.uninitializedWallet {
            do {
                if try environment.databaseFiles.areDbFilesPresentFor(
                    environment.zcashSDKEnvironment.network
                ) {
                    return .keysMissing
                }
            } catch {
                return .uninitialized
            }
        } catch {
            return .failed
        }
        
        return .uninitialized
    }
    
    static func prepareInitializer(
        for seedPhrase: String,
        birthday: BlockHeight,
        with environment: AppEnvironment
    ) throws -> Initializer {
        do {
            let seedBytes = try environment.mnemonicSeedPhraseProvider.toSeed(seedPhrase)
            let viewingKeys = try environment.wrappedDerivationTool.deriveUnifiedViewingKeysFromSeed(seedBytes, 1)
            
            let network = environment.zcashSDKEnvironment.network
            
            let initializer = Initializer(
                cacheDbURL: try environment.databaseFiles.cacheDbURLFor(network),
                dataDbURL: try environment.databaseFiles.dataDbURLFor(network),
                pendingDbURL: try environment.databaseFiles.pendingDbURLFor(network),
                endpoint: environment.zcashSDKEnvironment.endpoint,
                network: environment.zcashSDKEnvironment.network,
                spendParamsURL: try environment.databaseFiles.spendParamsURLFor(network),
                outputParamsURL: try environment.databaseFiles.outputParamsURLFor(network),
                viewingKeys: viewingKeys,
                walletBirthday: birthday
            )
            
            return initializer
        } catch {
            throw SDKInitializationError.failed
        }
    }
}

// MARK: - AppStore

typealias AppStore = Store<AppState, AppAction>

extension AppStore {
    static var placeholder: AppStore {
        AppStore(
            initialState: .placeholder,
            reducer: .default,
            environment: .live
        )
    }
}

// MARK: - AppViewStore

typealias AppViewStore = ViewStore<AppState, AppAction>

extension AppViewStore {
}

// MARK: PlaceHolders

extension AppState {
    static var placeholder: Self {
        .init(
            homeState: .placeholder,
            onboardingState: .init(
                importWalletState: .placeholder
            ),
            phraseValidationState: RecoveryPhraseValidationState.placeholder,
            phraseDisplayState: RecoveryPhraseDisplayState(
                phrase: .placeholder
            ),
            sandboxState: .placeholder,
            welcomeState: .placeholder
        )
    }
}
