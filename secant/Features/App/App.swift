import ComposableArchitecture
import ZcashLightClientKit

struct AppState: Equatable {
    enum Route: Equatable {
        case welcome
        case startup
        case onboarding
        case home
        case phraseValidation
        case phraseDisplay
    }
    
    var homeState: HomeState
    var onboardingState: OnboardingState
    var phraseValidationState: RecoveryPhraseValidationState
    var phraseDisplayState: RecoveryPhraseDisplayState
    var welcomeState: WelcomeState
    var route: Route = .welcome
    var storedWallet: StoredWallet?
    var appInitializationState: InitializationState = .uninitialized
}

enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case checkWalletInitialization
    case createNewWallet
    case home(HomeAction)
    case initializeApp
    case nukeWallet
    case onboarding(OnboardingAction)
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case phraseValidation(RecoveryPhraseValidationAction)
    case respondToWalletInitializationState(InitializationState)
    case updateRoute(AppState.Route)
    case welcome(WelcomeAction)
}

struct AppEnvironment {
    let databaseFiles: DatabaseFilesInteractor
    let scheduler: AnySchedulerOf<DispatchQueue>
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let walletStorage: WalletStorageInteractor
    let wrappedDerivationTool: WrappedDerivationTool
}

extension AppEnvironment {
    static let live = AppEnvironment(
        databaseFiles: .live(),
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        mnemonicSeedPhraseProvider: .live,
        walletStorage: .live(),
        wrappedDerivationTool: .live()
    )

    static let mock = AppEnvironment(
        databaseFiles: .live(),
        scheduler: DispatchQueue.main.eraseToAnyScheduler(),
        mnemonicSeedPhraseProvider: .mock,
        walletStorage: .live(),
        wrappedDerivationTool: .live(derivationTool: DerivationTool(networkType: .testnet))
    )
}

// MARK: - AppReducer

private struct ListenerId: Hashable {}

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

extension AppReducer {
    static let `default` = AppReducer.combine(
        [
            appReducer,
            routeReducer,
            homeReducer,
            onboardingReducer,
            phraseValidationReducer,
            phraseDisplayReducer
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
            case .initialized:
                return Effect(value: .initializeApp)
            case .keysMissing:
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.appInitializationState = .keysMissing
            case .filesMissing:
                state.appInitializationState = .filesMissing
                return Effect(value: .initializeApp)
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
        case .initializeApp:
            do {
                state.storedWallet = try environment.walletStorage.exportWallet()
            } catch {
                state.appInitializationState = .failed
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
            }
            
            guard let storedWallet = state.storedWallet else {
                return Effect(value: .updateRoute(.onboarding))
                    .delay(for: 3, scheduler: environment.scheduler)
                    .eraseToEffect()
                    .cancellable(id: ListenerId(), cancelInFlight: true)
            }

            var landingRoute: AppState.Route = .startup
            
            if !storedWallet.hasUserPassedPhraseBackupTest {
                let phraseWords: [String]
                do {
                    phraseWords = try environment.mnemonicSeedPhraseProvider.asWords(storedWallet.seedPhrase)
                } catch {
                    // TODO: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                    return .none
                }
                let recoveryPhrase = RecoveryPhrase(words: phraseWords)
                state.phraseDisplayState.phrase = recoveryPhrase
                state.phraseValidationState = RecoveryPhraseValidationState.random(phrase: recoveryPhrase)
                landingRoute = .phraseDisplay
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
                let randomPhraseWords = try environment.mnemonicSeedPhraseProvider.asWords(randomPhrase)
                // TODO: - Get birthday from the integrated SDK, issue 228 (https://github.com/zcash/secant-ios-wallet/issues/228)
                // get the latest block height
                let birthday = BlockHeight(12345678)
                
                // store the wallet to the keychain
                try environment.walletStorage.importWallet(randomPhrase, birthday, .english, false)
                
                // start the backup phrase validation test
                let recoveryPhrase = RecoveryPhrase(words: randomPhraseWords)
                state.phraseDisplayState.phrase = recoveryPhrase
                state.phraseValidationState = RecoveryPhraseValidationState.random(phrase: recoveryPhrase)
                
                return Effect(value: .phraseValidation(.displayBackedUpPhrase))
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
            // TODO: - when DatabaseFiles dependency is merged, nukeFiles as well, issue #220 (https://github.com/zcash/secant-ios-wallet/issues/220)
            return .none
            
        case .welcome(.debugMenuHome):
            return .concatenate(
                Effect.cancel(id: ListenerId()),
                Effect(value: .updateRoute(.home))
            )
            
        case .welcome(.debugMenuStartup):
            return .concatenate(
                Effect.cancel(id: ListenerId()),
                Effect(value: .updateRoute(.startup))
            )
            
        case .onboarding(.importWallet(.successfullyRecovered)):
            return Effect(value: .updateRoute(.home))
        
            /// Default is meaningful here because there's `routeReducer` handling routes and this reducer is handling only actions. We don't here plenty of unused cases.
        default:
            return .none
        }
    }

    private static let routeReducer = AppReducer { state, action, _ in
        switch action {
        case let .updateRoute(route):
            state.route = route

        case .home(.reset):
            state.route = .startup

        case .onboarding(.createNewWallet):
            return Effect(value: .createNewWallet)

        case .phraseValidation(.proceedToHome):
            state.route = .home

        case .phraseValidation(.displayBackedUpPhrase),
            .phraseDisplay(.createPhrase):
            state.route = .phraseDisplay

        case .phraseDisplay(.finishedPressed):
            state.route = .phraseValidation

            /// Default is meaningful here because there's `appReducer` handling actions and this reducer is handling only routes. We don't here plenty of unused cases.
        default:
            break
        }

        return .none
    }

    private static let homeReducer: AppReducer = HomeReducer.default.pullback(
        state: \AppState.homeState,
        action: /AppAction.home,
        environment: { _ in }
    )

    private static let onboardingReducer: AppReducer = OnboardingReducer.default.pullback(
        state: \AppState.onboardingState,
        action: /AppAction.onboarding,
        environment: { environment in
            OnboardingEnvironment(
                mnemonicSeedPhraseProvider: environment.mnemonicSeedPhraseProvider,
                walletStorage: environment.walletStorage
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
            // TODO: replace the hardcoded network with the environmental value, issue 239 (https://github.com/zcash/secant-ios-wallet/issues/239)
            let databaseFilesPresent = try environment.databaseFiles.areDbFilesPresentFor("mainnet")
            
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
                // TODO: replace the hardcoded network with the environmental value, issue 239 (https://github.com/zcash/secant-ios-wallet/issues/239)
                _ = try environment.databaseFiles.areDbFilesPresentFor("mainnet")
                
                return .keysMissing
            } catch {
                return .uninitialized
            }
        } catch {
            return .failed
        }
        
        return .uninitialized
    }
}

// MARK: - AppStore

typealias AppStore = Store<AppState, AppAction>

extension AppStore {
    static var placeholder: AppStore {
        AppStore(
            initialState: .placeholder,
            reducer: .default,
            environment: .mock
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
            welcomeState: .placeholder
        )
    }
}
