import ComposableArchitecture
import ZcashLightClientKit

typealias RootStore = Store<RootReducer.State, RootReducer.Action>
typealias RootViewStore = ViewStore<RootReducer.State, RootReducer.Action>

struct RootReducer: ReducerProtocol {
    enum CancelId {}
    enum SynchronizerCancelId {}
    enum WalletConfigCancelId {}

    struct State: Equatable {
        @BindingState var alert: AlertState<RootReducer.Action>?
        var appInitializationState: InitializationState = .uninitialized
        var destinationState: DestinationState
        var homeState: HomeReducer.State
        var onboardingState: OnboardingFlowReducer.State
        var phraseValidationState: RecoveryPhraseValidationFlowReducer.State
        var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        var sandboxState: SandboxReducer.State
        var storedWallet: StoredWallet?
        var walletConfig: WalletConfig
        var welcomeState: WelcomeReducer.State
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<RootReducer.State>)
        case debug(DebugAction)
        case dismissAlert
        case destination(DestinationAction)
        case home(HomeReducer.Action)
        case initialization(InitializationAction)
        case nukeWalletFailed
        case nukeWalletSucceeded
        case onboarding(OnboardingFlowReducer.Action)
        case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case phraseValidation(RecoveryPhraseValidationFlowReducer.Action)
        case sandbox(SandboxReducer.Action)
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

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.homeState, action: /Action.home) {
            HomeReducer()
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
            let databaseFilesPresent = try databaseFiles.areDbFilesPresentFor(
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
        } catch DatabaseFiles.DatabaseFilesError.filesPresentCheck {
            if keysPresent {
                return .filesMissing
            }
        } catch WalletStorage.WalletStorageError.uninitializedWallet {
            do {
                if try databaseFiles.areDbFilesPresentFor(
                    zcashSDKEnvironment.network
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
    
    // swiftlint:disable function_parameter_count
    static func prepareInitializer(
        for seedPhrase: String,
        birthday: BlockHeight,
        databaseFiles: DatabaseFilesClient,
        derivationTool: DerivationToolClient,
        mnemonic: MnemonicClient,
        zcashSDKEnvironment: ZcashSDKEnvironment
    ) throws -> Initializer {
        do {
            let seedBytes = try mnemonic.toSeed(seedPhrase)
            let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0)
            let viewingKey = try spendingKey.deriveFullViewingKey()
            let network = zcashSDKEnvironment.network

            let initializer = Initializer(
                cacheDbURL: try databaseFiles.cacheDbURLFor(network),
                fsBlockDbRoot: try databaseFiles.fsBlockDbRootFor(network),
                dataDbURL: try databaseFiles.dataDbURLFor(network),
                pendingDbURL: try databaseFiles.pendingDbURLFor(network),
                endpoint: zcashSDKEnvironment.endpoint,
                network: zcashSDKEnvironment.network,
                spendParamsURL: try databaseFiles.spendParamsURLFor(network),
                outputParamsURL: try databaseFiles.outputParamsURLFor(network),
                saplingParamsSourceURL: SaplingParamsSourceURL.default,
                viewingKeys: [viewingKey],
                walletBirthday: birthday,
                loggerProxy: OSLogger(logLevel: .debug, category: LoggerConstants.sdkLogs)
            )
            
            return initializer
        } catch {
            throw SDKInitializationError.failed
        }
    }
}

// MARK: Placeholders

extension RootReducer.State {
    static var placeholder: Self {
        .init(
            destinationState: .placeholder,
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
            reducer: RootReducer().logging()._printChanges()
        )
    }
}
