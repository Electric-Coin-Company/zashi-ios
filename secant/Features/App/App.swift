import ComposableArchitecture

struct AppState: Equatable {
    enum Route {
        case startup
        case onboarding
        case home
        case phraseValidation
    }
    var homeState: HomeState
    var onboardingState: OnboardingState
    var phraseValidationState: RecoveryPhraseValidationState
    var route: Route = .startup
}

enum AppAction: Equatable {
    case updateRoute(AppState.Route)
    case home(HomeAction)
    case onboarding(OnboardingAction)
    case phraseValidation(RecoveryPhraseValidationAction)
}

struct AppEnvironment: Equatable {
}

// MARK: - AppReducer

typealias AppReducer = Reducer<AppState, AppAction, AppEnvironment>

extension AppReducer {
    static let `default` = AppReducer.combine(
        [
            routeReducer,
            homeReducer,
            onboardingReducer,
            phraseValidationReducer.debug()
        ]
    )

    private static let routeReducer = AppReducer { state, action, _ in
        switch action {
        case let .updateRoute(route):
            state.route = route
        case .home(.reset):
            state.route = .startup
        case .onboarding(.createNewWallet), .phraseValidation(.proceedToHome):
            state.route = .home
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
            onboardingState: .init(),
            phraseValidationState: RecoveryPhraseValidationState.placeholder
        )
    }
}
