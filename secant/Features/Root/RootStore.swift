import ComposableArchitecture
import ZcashLightClientKit

typealias RootStore = Store<RootReducer.State, RootReducer.Action>
typealias RootViewStore = ViewStore<RootReducer.State, RootReducer.Action>

struct RootReducer: ReducerProtocol {
    enum CancelId {}
    enum SynchronizerCancelId {}
    enum WalletConfigCancelId {}

    struct State: Equatable {
        var appInitializationState: InitializationState = .uninitialized
        var debugState: DebugState
        var destinationState: DestinationState
        var exportLogsState: ExportLogsReducer.State
        var homeState: HomeReducer.State
        var onboardingState: OnboardingFlowReducer.State
        var phraseValidationState: RecoveryPhraseValidationFlowReducer.State
        var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        var sandboxState: SandboxReducer.State
        var storedWallet: StoredWallet?
        @BindingState var uniAlert: AlertState<RootReducer.Action>?
        var walletConfig: WalletConfig
        var welcomeState: WelcomeReducer.State
    }

    enum Action: Equatable, BindableAction {
        case alert(AlertRequest)
        case binding(BindingAction<RootReducer.State>)
        case debug(DebugAction)
        case dismissAlert
        case destination(DestinationAction)
        case exportLogs(ExportLogsReducer.Action)
        case home(HomeReducer.Action)
        case initialization(InitializationAction)
        case nukeWalletFailed
        case nukeWalletSucceeded
        case onboarding(OnboardingFlowReducer.Action)
        case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case phraseValidation(RecoveryPhraseValidationFlowReducer.Action)
        case sandbox(SandboxReducer.Action)
        case uniAlert(AlertAction)
        case updateStateAfterConfigUpdate(WalletConfig)
        case walletConfigLoaded(WalletConfig)
        case welcome(WelcomeReducer.Action)
    }

    @Dependency(\.crashReporter) var crashReporter
    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.deeplink) var deeplink
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.randomRecoveryPhrase) var randomRecoveryPhrase
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.walletConfigProvider) var walletConfigProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.homeState, action: /Action.home) {
            HomeReducer()
        }

        Scope(state: \.exportLogsState, action: /Action.exportLogs) {
            ExportLogsReducer()
        }

        Scope(state: \.onboardingState, action: /Action.onboarding) {
            OnboardingFlowReducer()
        }

        Scope(state: \.phraseValidationState, action: /Action.phraseValidation) {
            RecoveryPhraseValidationFlowReducer()
        }

        Scope(state: \.phraseDisplayState, action: /Action.phraseDisplay) {
            RecoveryPhraseDisplayReducer()
        }

        Scope(state: \.sandboxState, action: /Action.sandbox) {
            SandboxReducer()
        }

        Scope(state: \.welcomeState, action: /Action.welcome) {
            WelcomeReducer()
        }

        initializationReduce()

        destinationReduce()
        
        debugReduce()
    }
    
    var body: some ReducerProtocol<State, Action> {
        self.core
            .alerts()
    }
}

extension RootReducer {
    static func walletInitializationState(
        databaseFiles: DatabaseFilesClient,
        walletStorage: WalletStorageClient,
        zcashSDKEnvironment: ZcashSDKEnvironment
    ) -> InitializationState {
        var keysPresent = false
        do {
            keysPresent = try walletStorage.areKeysPresent()
            let databaseFilesPresent = databaseFiles.areDbFilesPresentFor(
                zcashSDKEnvironment.network
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
        } catch WalletStorage.WalletStorageError.uninitializedWallet {
            if databaseFiles.areDbFilesPresentFor(zcashSDKEnvironment.network) {
                return .keysMissing
            }
        } catch {
            return .failed
        }
        
        return .uninitialized
    }
}

// MARK: Placeholders

extension RootReducer.State {
    static var placeholder: Self {
        .init(
            debugState: .placeholder,
            destinationState: .placeholder,
            exportLogsState: .placeholder,
            homeState: .placeholder,
            onboardingState: .init(
                walletConfig: .default,
                importWalletState: .placeholder
            ),
            phraseValidationState: .placeholder,
            phraseDisplayState: RecoveryPhraseDisplayReducer.State(
                phrase: .placeholder
            ),
            sandboxState: .placeholder,
            walletConfig: .default,
            welcomeState: .placeholder
        )
    }
}

extension RootStore {
    static var placeholder: RootStore {
        RootStore(
            initialState: .placeholder,
            reducer: RootReducer().logging()
        )
    }
}
