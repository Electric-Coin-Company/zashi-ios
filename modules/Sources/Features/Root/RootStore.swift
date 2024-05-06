import ComposableArchitecture
import ZcashLightClientKit
import DatabaseFiles
import Deeplink
import DiskSpaceChecker
import ZcashSDKEnvironment
import WalletStorage
import WalletConfigProvider
import UserPreferencesStorage
import Models
import NotEnoughFreeSpace
import Welcome
import Generated
import Foundation
import ExportLogs
import OnboardingFlow
import Sandbox
import Tabs
import CrashReporter
import ReadTransactionsStorage
import RecoveryPhraseDisplay
import BackgroundTasks
import RestoreWalletStorage
import Utils
import UserDefaults
import HideBalances

public typealias RootStore = Store<RootReducer.State, RootReducer.Action>
public typealias RootViewStore = ViewStore<RootReducer.State, RootReducer.Action>

public struct RootReducer: Reducer {
    let CancelId = UUID()
    let CancelStateId = UUID()
    let SynchronizerCancelId = UUID()
    let WalletConfigCancelId = UUID()
    let DidFinishLaunchingId = UUID()

    public struct State: Equatable {
        @PresentationState public var alert: AlertState<Action>?
        public var appInitializationState: InitializationState = .uninitialized
        public var appStartState: AppStartState = .unknown
        public var bgTask: BGProcessingTask?
        @PresentationState public var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        public var debugState: DebugState
        public var destinationState: DestinationState
        public var exportLogsState: ExportLogsReducer.State
        public var isLockedInKeychainUnavailableState = false
        public var isRestoringWallet = false
        public var notEnoughFreeSpaceState: NotEnoughFreeSpace.State
        public var onboardingState: OnboardingFlowReducer.State
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        public var sandboxState: SandboxReducer.State
        public var splashAppeared = false
        public var tabsState: TabsReducer.State
        public var walletConfig: WalletConfig
        public var welcomeState: WelcomeReducer.State
        
        public init(
            appInitializationState: InitializationState = .uninitialized,
            appStartState: AppStartState = .unknown,
            debugState: DebugState,
            destinationState: DestinationState,
            exportLogsState: ExportLogsReducer.State,
            isLockedInKeychainUnavailableState: Bool = false,
            isRestoringWallet: Bool = false,
            notEnoughFreeSpaceState: NotEnoughFreeSpace.State = .initial,
            onboardingState: OnboardingFlowReducer.State,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            sandboxState: SandboxReducer.State,
            tabsState: TabsReducer.State,
            walletConfig: WalletConfig,
            welcomeState: WelcomeReducer.State
        ) {
            self.appInitializationState = appInitializationState
            self.appStartState = appStartState
            self.debugState = debugState
            self.destinationState = destinationState
            self.exportLogsState = exportLogsState
            self.isLockedInKeychainUnavailableState = isLockedInKeychainUnavailableState
            self.isRestoringWallet = isRestoringWallet
            self.onboardingState = onboardingState
            self.notEnoughFreeSpaceState = notEnoughFreeSpaceState
            self.phraseDisplayState = phraseDisplayState
            self.sandboxState = sandboxState
            self.tabsState = tabsState
            self.walletConfig = walletConfig
            self.welcomeState = welcomeState
        }
    }

    public enum Action: Equatable {
        public enum ConfirmationDialog: Equatable {
            case fullRescan
            case quickRescan
        }

        case alert(PresentationAction<Action>)
        case binding(BindingAction<RootReducer.State>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case debug(DebugAction)
        case destination(DestinationAction)
        case exportLogs(ExportLogsReducer.Action)
        case tabs(TabsReducer.Action)
        case initialization(InitializationAction)
        case notEnoughFreeSpace(NotEnoughFreeSpace.Action)
        case nukeWalletFailed
        case nukeWalletSucceeded
        case onboarding(OnboardingFlowReducer.Action)
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case splashFinished
        case splashRemovalRequested
        case sandbox(SandboxReducer.Action)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateStateAfterConfigUpdate(WalletConfig)
        case walletConfigLoaded(WalletConfig)
        case welcome(WelcomeReducer.Action)
    }

    @Dependency(\.crashReporter) var crashReporter
    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.deeplink) var deeplink
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.hideBalances) var hideBalances
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.walletConfigProvider) var walletConfigProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Scope(state: \.tabsState, action: /Action.tabs) {
            TabsReducer()
        }

        Scope(state: \.exportLogsState, action: /Action.exportLogs) {
            ExportLogsReducer()
        }

        Scope(state: \.notEnoughFreeSpaceState, action: /Action.notEnoughFreeSpace) {
            NotEnoughFreeSpace()
        }

        Scope(state: \.onboardingState, action: /Action.onboarding) {
            OnboardingFlowReducer()
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
    
    public var body: some Reducer<State, Action> {
        self.core

        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            default: return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
    }
}

extension RootReducer {
    public static func walletInitializationState(
        databaseFiles: DatabaseFilesClient,
        walletStorage: WalletStorageClient,
        zcashNetwork: ZcashNetwork
    ) -> InitializationState {
        var keysPresent = false
        do {
            keysPresent = try walletStorage.areKeysPresent()
            let databaseFilesPresent = databaseFiles.areDbFilesPresentFor(zcashNetwork)
            
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
            if databaseFiles.areDbFilesPresentFor(zcashNetwork) {
                return .keysMissing
            }
        } catch {
            return .failed
        }
        
        return .uninitialized
    }
}

// MARK: Alerts

extension AlertState where Action == RootReducer.Action {
    public static func cantLoadSeedPhrase() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.CantLoadSeedPhrase.message)
        }
    }
    
    public static func cantStartSync(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.title)
        } message: {
            TextState(L10n.Root.Debug.Alert.Rewind.CantStartSync.message(error.detailedMessage))
        }
    }
    
    public static func cantStoreThatUserPassedPhraseBackupTest(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(
                L10n.Root.Initialization.Alert.CantStoreThatUserPassedPhraseBackupTest.message(error.detailedMessage)
            )
        }
    }
    
    public static func failedToProcessDeeplink(_ url: URL, _ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.title)
        } message: {
            TextState(L10n.Root.Destination.Alert.FailedToProcessDeeplink.message(url, error.message, error.code.rawValue))
        }
    }
    
    public static func initializationFailed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.SdkInitFailed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.Error.message(error.detailedMessage))
        }
    }
    
    public static func rewindFailed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Debug.Alert.Rewind.Failed.title)
        } message: {
            TextState(L10n.Root.Debug.Alert.Rewind.Failed.message(error.detailedMessage))
        }
    }
    
    public static func walletStateFailed(_ walletState: InitializationState) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.WalletStateFailed.message(walletState))
        }
    }
    
    public static func wipeFailed() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.WipeFailed.title)
        }
    }
    
    public static func wipeRequest() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Wipe.title)
        } actions: {
            ButtonState(role: .destructive, action: .initialization(.nukeWallet)) {
                TextState(L10n.General.yes)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.no)
            }
        } message: {
            TextState(L10n.Root.Initialization.Alert.Wipe.message)
        }
    }
    
    public static func successfullyRecovered() -> AlertState {
        AlertState {
            TextState(L10n.General.success)
        } message: {
            TextState(L10n.ImportWallet.Alert.Success.message)
        }
    }
    
    public static func differentSeed() -> AlertState {
        AlertState {
            TextState("Warning")
        } actions: {
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState("Try Again")
            }
            ButtonState(role: .destructive, action: .initialization(.nukeWallet)) {
                TextState("Continue")
            }
        } message: {
            TextState("This recovery phrase doesn't match the Zashi database backup saved on this device. If you proceed, you will lose access to this database backup and if you try to restore later, some information may be lost.")
        }
    }
    
    public static func existingWallet() -> AlertState {
        AlertState {
            TextState("Warning")
        } actions: {
            ButtonState(role: .cancel, action: .initialization(.restoreExistingWallet)) {
                TextState("Restore")
            }
            ButtonState(role: .destructive, action: .initialization(.nukeWallet)) {
                TextState("Continue")
            }
        } message: {
            TextState("We identified a Zashi database backup on this device. If you create a new wallet, you will lose access to this database backup and if you try to restore later, some information may be lost.")
        }
    }
}
     
extension ConfirmationDialogState where Action == RootReducer.Action.ConfirmationDialog {
    public static func rescanRequest() -> ConfirmationDialogState {
        ConfirmationDialogState {
            TextState(L10n.Root.Debug.Dialog.Rescan.title)
        } actions: {
            ButtonState(role: .destructive, action: .quickRescan) {
                TextState(L10n.Root.Debug.Dialog.Rescan.Option.quick)
            }
            ButtonState(role: .destructive, action: .fullRescan) {
                TextState(L10n.Root.Debug.Dialog.Rescan.Option.full)
            }
            ButtonState(role: .cancel) {
                TextState(L10n.General.cancel)
            }
        } message: {
            TextState(L10n.Root.Debug.Dialog.Rescan.message)
        }
    }

}

// MARK: Placeholders

extension RootReducer.State {
    public static var initial: Self {
        .init(
            debugState: .initial,
            destinationState: .initial,
            exportLogsState: .initial,
            onboardingState: .initial,
            phraseDisplayState: .initial,
            sandboxState: .initial,
            tabsState: .initial,
            walletConfig: .initial,
            welcomeState: .initial
        )
    }
}

extension RootStore {
    public static var placeholder: RootStore {
        RootStore(
            initialState: .initial
        ) {
            RootReducer()
                .logging()
        }
    }
}
