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
}

enum AppAction: Equatable {
    case createNewWallet
    case updateRoute(AppState.Route)
    case home(HomeAction)
    case onboarding(OnboardingAction)
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case phraseValidation(RecoveryPhraseValidationAction)
}

struct AppEnvironment {
    let mnemonicSeedPhraseProvider: MnemonicSeedPhraseProvider
    let walletStorage: RecoveryPhraseStorage
}

extension AppEnvironment {
    static let live = AppEnvironment(
        mnemonicSeedPhraseProvider: .live,
        walletStorage: RecoveryPhraseStorage()
    )

    static let mock = AppEnvironment(
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
