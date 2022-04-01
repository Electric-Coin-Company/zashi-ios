import ComposableArchitecture

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
    var route: Route = .welcome
    var storedWallet: StoredWallet?
    var appInitialisationState: InitialisationState = .uninitialized
}

enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case checkWalletInitialisation
    case createNewWallet
    case home(HomeAction)
    case initializeApp
    case onboarding(OnboardingAction)
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case phraseValidation(RecoveryPhraseValidationAction)
    case updateRoute(AppState.Route)
    case walletInitialisationResult(InitialisationState)
}

struct AppEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let walletStorage: RecoveryPhraseStorage
}

extension AppEnvironment {
    static let live = AppEnvironment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        mnemonicSeedPhraseProvider: .live,
        walletStorage: RecoveryPhraseStorage()
    )

    static let mock = AppEnvironment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        mnemonicSeedPhraseProvider: .mock,
        walletStorage: RecoveryPhraseStorage()
    )
}

// MARK: - AppReducer

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
        case .createNewWallet:
            let randomPhraseWords: [String]
            do {
                let randomPhrase = try environment.mnemonicSeedPhraseProvider.randomMnemonic()
                randomPhraseWords = try environment.mnemonicSeedPhraseProvider.asWords(randomPhrase)
                // TODO: - Get birthday from the integrated SDK, issue 228 (https://github.com/zcash/secant-ios-wallet/issues/228)
                let birthday = BlockHeight(12345678)
                
                try environment.walletStorage.importRecoveryPhrase(bip39: randomPhrase, birthday: birthday)
            } catch {
                // TODO: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                return .none
            }
            
            let recoveryPhrase = RecoveryPhrase(words: randomPhraseWords)
            state.phraseDisplayState.phrase = recoveryPhrase
            state.phraseValidationState = RecoveryPhraseValidationState.random(phrase: recoveryPhrase)
            
            return Effect(value: .phraseValidation(.displayBackedUpPhrase))

            /// Checking presense of stored wallet in the keychain and presense of database files in documents directory.
        case .checkWalletInitialisation:
            var walletInitialisationState: InitialisationState = .uninitialized

            // TODO: Create a dependency to handle database files for the SDK, issue #220 (https://github.com/zcash/secant-ios-wallet/issues/220)
            let fileManager = FileManager()
            // TODO: use updated dependency from PR #217 (https://github.com/zcash/secant-ios-wallet/pull/217)
            let keysPresent = environment.walletStorage.areKeysPresent()
            
            do {
                // TODO: use database URL from the same issue #220
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let dataDatabaseURL = documentsURL.appendingPathComponent("ZcashSDK.defaultDataDbName", isDirectory: false)
                let attributes = try fileManager.attributesOfItem(atPath: dataDatabaseURL.path)
                let databaseFilesPresent = attributes.isEmpty
                
                switch (keysPresent, databaseFilesPresent) {
                case (false, false):
                    walletInitialisationState = .uninitialized
                case (false, true):
                    walletInitialisationState = .keysMissingFilesPresent
                case (true, false):
                    walletInitialisationState = .keysPresentFilesMissing
                case (true, true):
                    walletInitialisationState = .initialized
                }
            } catch CocoaError.fileNoSuchFile, CocoaError.fileReadNoSuchFile {
                walletInitialisationState = keysPresent ? .keysPresentFilesMissing : .uninitialized
            } catch {
                walletInitialisationState = .failure(ErrorWrapper(error: error))
            }
            
            return Effect(value: .walletInitialisationResult(walletInitialisationState))

            /// All possible responses to the `.checkWalletInitialisation` action result.
            /// `uninitialized` results in the start of the Onboarding flow for the user.
        case .walletInitialisationResult(let walletInitialisationState):
            switch walletInitialisationState {
            case .uninitialized:
                return Effect(value: .updateRoute(.onboarding))
                    .delay(for: 3, scheduler: environment.mainQueue)
                    .eraseToEffect()
            case .initialized, .keysPresentFilesMissing:
                return Effect(value: .initializeApp)
            case .keysMissingFilesPresent:
                state.appInitialisationState = walletInitialisationState
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
            case .failure(error: let error):
                state.appInitialisationState = walletInitialisationState
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
            }

            /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
            /// When initialization succeeds user is taken to the home screen.
        case .initializeApp:
            do {
                state.storedWallet = try environment.walletStorage.exportWallet()
            } catch {
                state.appInitialisationState = .failure(ErrorWrapper(error: error))
                // TODO: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                return .none
            }
            
            state.appInitialisationState = .initialized
            return Effect(value: .updateRoute(.startup))
                .delay(for: 3, scheduler: environment.mainQueue)
                .eraseToEffect()

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
        environment: { _ in }
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
            )
        )
    }
}
