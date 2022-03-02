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
    case updateRoute(AppState.Route)
    case home(HomeAction)
    case onboarding(OnboardingAction)
    case phraseDisplay(RecoveryPhraseDisplayAction)
    case phraseValidation(RecoveryPhraseValidationAction)
}

struct AppEnvironment: Equatable {}

// MARK: - AppReducer

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

extension AppReducer {
    static let `default` = AppReducer.combine(
        [
            routeReducer,
            homeReducer,
            onboardingReducer,
            phraseValidationReducer,
            phraseDisplayReducer
        ]
    )
    .debug()

    private static let routeReducer = AppReducer { state, action, _ in
        switch action {
        case let .updateRoute(route):
            state.route = route

        case .home(.reset):
            state.route = .startup

        case .onboarding(.createNewWallet),
            .phraseValidation(.proceedToHome):
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
