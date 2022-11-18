import ComposableArchitecture
import ZcashLightClientKit
import Foundation

typealias AppStore = Store<AppReducer.State, AppReducer.Action>
typealias AppViewStore = ViewStore<AppReducer.State, AppReducer.Action>

// swiftlint:disable type_body_length
struct AppReducer: ReducerProtocol {
    private enum CancelId {}

    struct State: Equatable {
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
        var homeState: HomeReducer.State
        var onboardingState: OnboardingFlowReducer.State
        var phraseValidationState: RecoveryPhraseValidationFlowReducer.State
        var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        var prevRoute: Route?
        var internalRoute: Route = .welcome
        var sandboxState: SandboxReducer.State
        var storedWallet: StoredWallet?
        var welcomeState: WelcomeReducer.State
        
        var route: Route {
            get { internalRoute }
            set {
                prevRoute = internalRoute
                internalRoute = newValue
            }
        }
    }

    enum Action: Equatable {
        case appDelegate(AppDelegateAction)
        case checkBackupPhraseValidation
        case checkWalletInitialization
        case createNewWallet
        case deeplink(URL)
        case deeplinkHome
        case deeplinkSend(Zatoshi, String, String)
        case home(HomeReducer.Action)
        case initializeSDK
        case nukeWallet
        case onboarding(OnboardingFlowReducer.Action)
        case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case phraseValidation(RecoveryPhraseValidationFlowReducer.Action)
        case respondToWalletInitializationState(InitializationState)
        case sandbox(SandboxReducer.Action)
        case updateRoute(AppReducer.State.Route)
        case welcome(WelcomeReducer.Action)
    }
    
    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.deeplink) var deeplink
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.randomRecoveryPhrase) var randomRecoveryPhrase
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
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

        Reduce { state, action in
            switch action {
            case let .updateRoute(route):
                state.route = route
                
            case .sandbox(.reset):
                state.route = .startup
                
            case .onboarding(.createNewWallet):
                return Effect(value: .createNewWallet)
                
            case .phraseValidation(.proceedToHome):
                state.route = .home
                
            case .phraseValidation(.displayBackedUpPhrase):
                state.route = .phraseDisplay
                
            case .phraseDisplay(.finishedPressed):
                // user is still supposed to do the backup phrase validation test
                if state.prevRoute == .welcome || state.prevRoute == .onboarding {
                    state.route = .phraseValidation
                }
                // user wanted to see the backup phrase once again (at validation finished screen)
                if state.prevRoute == .phraseValidation {
                    state.route = .home
                }
                
            case .deeplink(let url):
                // get the latest synchronizer state
                var synchronizerStatus = SDKSynchronizerState.unknown
                _ = sdkSynchronizer.stateChanged.sink { synchronizerStatus = $0 }
                
                // process the deeplink only if app is initialized and synchronizer synced
                guard state.appInitializationState == .initialized && synchronizerStatus == .synced else {
                    // TODO [#370]: There are many different states and edge cases we need to handle here
                    // (https://github.com/zcash/secant-ios-wallet/issues/370)
                    return .none
                }
                return .run { send in
                    do {
                        await send(
                            try await AppReducer.process(
                                url: url,
                                deeplink: deeplink,
                                derivationTool: derivationTool
                            )
                        )
                    } catch {
                        // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    }
                }
                
            case .deeplinkHome:
                state.route = .home
                state.homeState.route = nil
                return .none
                
            case let .deeplinkSend(amount, address, memo):
                state.route = .home
                state.homeState.route = .send
                state.homeState.sendState.amount = amount
                state.homeState.sendState.address = address
                state.homeState.sendState.memoState.text = memo
                return .none
                
            case .home(.walletEvents(.replyTo(let address))):
                guard let url = URL(string: "zcash:\(address)") else {
                    return .none
                }
                return Effect(value: .deeplink(url))
                
                /// Default is meaningful here because there's `appReducer` handling actions and this reducer is handling only routes. We don't here plenty of unused cases.
            default:
                break
            }
            
            return .none
        }
        
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                /// We need to fetch data from keychain, in order to be 100% sure the kecyhain can be read we delay the check a bit
                return Effect(value: .checkWalletInitialization)
                    .delay(for: 0.02, scheduler: mainQueue)
                    .eraseToEffect()
                
                /// Evaluate the wallet's state based on keychain keys and database files presence
            case .checkWalletInitialization:
                let walletState = AppReducer.walletInitializationState(
                    databaseFiles: databaseFiles,
                    walletStorage: walletStorage,
                    zcashSDKEnvironment: zcashSDKEnvironment
                )
                return Effect(value: .respondToWalletInitializationState(walletState))
                
                /// Respond to all possible states of the wallet and initiate appropriate side effects including errors handling
            case .respondToWalletInitializationState(let walletState):
                switch walletState {
                case .failed:
                    // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    state.appInitializationState = .failed
                case .keysMissing:
                    // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
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
                        .delay(for: 3, scheduler: mainQueue)
                        .eraseToEffect()
                        .cancellable(id: CancelId.self, cancelInFlight: true)
                }
                
                return .none

                /// Stored wallet is present, database files may or may not be present, trying to initialize app state variables and environments.
                /// When initialization succeeds user is taken to the home screen.
            case .initializeSDK:
                do {
                    state.storedWallet = try walletStorage.exportWallet()
                    
                    guard let storedWallet = state.storedWallet else {
                        state.appInitializationState = .failed
                        // TODO [#221]: fatal error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                        return .none
                    }
                    
                    try mnemonic.isValid(storedWallet.seedPhrase)
                    
                    let birthday = state.storedWallet?.birthday ?? zcashSDKEnvironment.defaultBirthday
                    
                    let initializer = try AppReducer.prepareInitializer(
                        for: storedWallet.seedPhrase,
                        birthday: birthday,
                        databaseFiles: databaseFiles,
                        derivationTool: derivationTool,
                        mnemonic: mnemonic,
                        zcashSDKEnvironment: zcashSDKEnvironment
                    )
                    try sdkSynchronizer.prepareWith(initializer: initializer)
                    try sdkSynchronizer.start()
                } catch {
                    state.appInitializationState = .failed
                    // TODO [#221]: error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                return .none

            case .checkBackupPhraseValidation:
                guard let storedWallet = state.storedWallet else {
                    state.appInitializationState = .failed
                    // TODO [#221]: fatal error we need to handle (https://github.com/zcash/secant-ios-wallet/issues/221)
                    return .none
                }

                var landingRoute: AppReducer.State.Route = .home
                
                if !storedWallet.hasUserPassedPhraseBackupTest {
                    do {
                        let phraseWords = try mnemonic.asWords(storedWallet.seedPhrase)
                        
                        let recoveryPhrase = RecoveryPhrase(words: phraseWords)
                        state.phraseDisplayState.phrase = recoveryPhrase
                        state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)
                        landingRoute = .phraseDisplay
                    } catch {
                        // TODO [#201]: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                        return .none
                    }
                }
                
                state.appInitializationState = .initialized
                
                return Effect(value: .updateRoute(landingRoute))
                    .delay(for: 3, scheduler: mainQueue)
                    .eraseToEffect()
                    .cancellable(id: CancelId.self, cancelInFlight: true)
                
            case .createNewWallet:
                do {
                    // get the random english mnemonic
                    let newRandomPhrase = try mnemonic.randomMnemonic()
                    let birthday = try zcashSDKEnvironment.lightWalletService.latestBlockHeight()
                    
                    // store the wallet to the keychain
                    try walletStorage.importWallet(newRandomPhrase, birthday, .english, false)
                    
                    // start the backup phrase validation test
                    let randomRecoveryPhraseWords = try mnemonic.asWords(newRandomPhrase)
                    let recoveryPhrase = RecoveryPhrase(words: randomRecoveryPhraseWords)
                    state.phraseDisplayState.phrase = recoveryPhrase
                    state.phraseValidationState = randomRecoveryPhrase.random(recoveryPhrase)
                    
                    return .concatenate(
                        Effect(value: .initializeSDK),
                        Effect(value: .phraseValidation(.displayBackedUpPhrase))
                    )
                } catch {
                    // TODO [#201]: - merge with issue 201 (https://github.com/zcash/secant-ios-wallet/issues/201) and its Error States
                }

                return .none

            case .phraseValidation(.succeed):
                do {
                    try walletStorage.markUserPassedPhraseBackupTest()
                } catch {
                    // TODO [#221]: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                return .none

            case .nukeWallet:
                walletStorage.nukeWallet()
                do {
                    try databaseFiles.nukeDbFilesFor(zcashSDKEnvironment.network)
                } catch {
                    // TODO [#221]: error we need to handle, issue #221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                }
                return .none

            case .welcome(.debugMenuStartup), .home(.debugMenuStartup):
                return .concatenate(
                    Effect.cancel(id: CancelId.self),
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
    }
}

extension AppReducer {
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
            let viewingKeys = try derivationTool.deriveUnifiedViewingKeysFromSeed(seedBytes, 1)
            
            let network = zcashSDKEnvironment.network
            
            let initializer = Initializer(
                cacheDbURL: try databaseFiles.cacheDbURLFor(network),
                dataDbURL: try databaseFiles.dataDbURLFor(network),
                pendingDbURL: try databaseFiles.pendingDbURLFor(network),
                endpoint: zcashSDKEnvironment.endpoint,
                network: zcashSDKEnvironment.network,
                spendParamsURL: try databaseFiles.spendParamsURLFor(network),
                outputParamsURL: try databaseFiles.outputParamsURLFor(network),
                viewingKeys: viewingKeys,
                walletBirthday: birthday
            )
            
            return initializer
        } catch {
            throw SDKInitializationError.failed
        }
    }

    static func process(
        url: URL,
        deeplink: DeeplinkClient,
        derivationTool: DerivationToolClient
    ) async throws -> AppReducer.Action {
        let deeplink = try deeplink.resolveDeeplinkURL(url, derivationTool)
        
        switch deeplink {
        case .home:
            return .deeplinkHome
        case let .send(amount, address, memo):
            return .deeplinkSend(Zatoshi(amount), address, memo)
        }
    }
}

// MARK: Placeholders

extension AppReducer.State {
    static var placeholder: Self {
        .init(
            homeState: .placeholder,
            onboardingState: .init(
                importWalletState: .placeholder
            ),
            phraseValidationState: .placeholder,
            phraseDisplayState: RecoveryPhraseDisplayReducer.State(
                phrase: .placeholder
            ),
            sandboxState: .placeholder,
            welcomeState: .placeholder
        )
    }
}

extension AppStore {
    static var placeholder: AppStore {
        AppStore(
            initialState: .placeholder,
            reducer: AppReducer()._printChanges()
        )
    }
}
