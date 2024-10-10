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
import Utils
import UserDefaults
import ServerSetup
import ExchangeRate
import FlexaHandler
import Flexa
import AutolockHandler
import UIComponents
import AddressBook
import LocalAuthenticationHandler
import DeeplinkWarning
import URIParser

@Reducer
public struct Root {
    let CancelId = UUID()
    let CancelStateId = UUID()
    let CancelBatteryStateId = UUID()
    let SynchronizerCancelId = UUID()
    let WalletConfigCancelId = UUID()
    let DidFinishLaunchingId = UUID()
    let CancelFlexaId = UUID()

    @ObservableState
    public struct State: Equatable {
        public var addressBookBinding: Bool = false
        public var addressBookContactBinding: Bool = false
        public var addressBookState: AddressBook.State
        @Presents public var alert: AlertState<Action>?
        public var appInitializationState: InitializationState = .uninitialized
        public var appStartState: AppStartState = .unknown
        public var bgTask: BGProcessingTask?
        @Presents public var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        public var debugState: DebugState
        public var deeplinkWarningState: DeeplinkWarning.State = .initial
        public var destinationState: DestinationState
        public var exportLogsState: ExportLogs.State
        public var isLockedInKeychainUnavailableState = false
        public var isRestoringWallet = false
        public var notEnoughFreeSpaceState: NotEnoughFreeSpace.State
        public var onboardingState: OnboardingFlow.State
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        public var sandboxState: Sandbox.State
        public var serverSetupState: ServerSetup.State
        public var serverSetupViewBinding: Bool = false
        public var splashAppeared = false
        public var tabsState: Tabs.State
        public var walletConfig: WalletConfig
        @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none
        public var wasRestoringWhenDisconnected = false
        public var welcomeState: Welcome.State
        
        public init(
            addressBookState: AddressBook.State = .initial,
            appInitializationState: InitializationState = .uninitialized,
            appStartState: AppStartState = .unknown,
            debugState: DebugState,
            destinationState: DestinationState,
            exportLogsState: ExportLogs.State,
            isLockedInKeychainUnavailableState: Bool = false,
            isRestoringWallet: Bool = false,
            notEnoughFreeSpaceState: NotEnoughFreeSpace.State = .initial,
            onboardingState: OnboardingFlow.State,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            sandboxState: Sandbox.State,
            tabsState: Tabs.State,
            serverSetupState: ServerSetup.State = .initial,
            walletConfig: WalletConfig,
            welcomeState: Welcome.State
        ) {
            self.addressBookState = addressBookState
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
            self.serverSetupState = serverSetupState
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

        case addressBook(AddressBook.Action)
        case addressBookBinding(Bool)
        case addressBookContactBinding(Bool)
        case addressBookAccessGranted
        case alert(PresentationAction<Action>)
        case batteryStateChanged(Notification)
        case binding(BindingAction<Root.State>)
        case cancelAllRunningEffects
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case debug(DebugAction)
        case deeplinkWarning(DeeplinkWarning.Action)
        case destination(DestinationAction)
        case exportLogs(ExportLogs.Action)
        case flexaOnTransactionRequest(FlexaTransaction?)
        case tabs(Tabs.Action)
        case initialization(InitializationAction)
        case notEnoughFreeSpace(NotEnoughFreeSpace.Action)
        case nukeWalletFailed
        case nukeWalletSucceeded
        case onboarding(OnboardingFlow.Action)
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case splashFinished
        case splashRemovalRequested
        case sandbox(Sandbox.Action)
        case serverSetup(ServerSetup.Action)
        case serverSetupBindingUpdated(Bool)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case updateStateAfterConfigUpdate(WalletConfig)
        case walletConfigLoaded(WalletConfig)
        case welcome(Welcome.Action)
    }

    @Dependency(\.autolockHandler) var autolockHandler
    @Dependency(\.crashReporter) var crashReporter
    @Dependency(\.databaseFiles) var databaseFiles
    @Dependency(\.deeplink) var deeplink
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.diskSpaceChecker) var diskSpaceChecker
    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.flexaHandler) var flexaHandler
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.numberFormatter) var numberFormatter
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.uriParser) var uriParser
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.walletConfigProvider) var walletConfigProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Scope(state: \.deeplinkWarningState, action: \.deeplinkWarning) {
            DeeplinkWarning()
        }
        
        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }
        
        Scope(state: \.serverSetupState, action: \.serverSetup) {
            ServerSetup()
        }

        Scope(state: \.tabsState, action: \.tabs) {
            Tabs()
        }

        Scope(state: \.exportLogsState, action: \.exportLogs) {
            ExportLogs()
        }

        Scope(state: \.notEnoughFreeSpaceState, action: \.notEnoughFreeSpace) {
            NotEnoughFreeSpace()
        }

        Scope(state: \.onboardingState, action: \.onboarding) {
            OnboardingFlow()
        }

        Scope(state: \.sandboxState, action: \.sandbox) {
            Sandbox()
        }

        Scope(state: \.welcomeState, action: \.welcome) {
            Welcome()
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
            
            case .addressBookBinding(let newValue):
                state.addressBookBinding = newValue
                return .none

            case .addressBookContactBinding(let newValue):
                state.addressBookContactBinding = newValue
                return .none

            case .tabs(.home(.transactionList(.saveAddressTapped(let address)))):
                state.addressBookContactBinding = true
                state.addressBookState.isValidZcashAddress = true
                state.addressBookState.isNameFocused = true
                state.addressBookState.address = address.data
                return .none

            case .tabs(.send(.addNewContactTapped(let address))):
                state.addressBookContactBinding = true
                state.addressBookState.isValidZcashAddress = true
                state.addressBookState.isNameFocused = true
                state.addressBookState.address = address.data
                return .none
                
            case .addressBook(.saveButtonTapped):
                if state.addressBookBinding {
                    state.addressBookBinding = false
                }
                if state.addressBookContactBinding {
                    state.addressBookContactBinding = false
                }
                return .none

            case .addressBookAccessGranted:
                state.addressBookBinding = true
                state.addressBookState.isInSelectMode = true
                return .none

            case .tabs(.send(.addressBookTapped)):
                return .run { send in
                    if await !localAuthentication.authenticate() {
                        return
                    }
                    await send(.addressBookAccessGranted)
                }

            case .addressBook(.editId(let address)):
                state.addressBookBinding = false
                return .send(.tabs(.send(.scan(.found(address.redacted)))))
                
            case .serverSetup:
                return .none
                
            case .serverSetupBindingUpdated(let newValue):
                state.serverSetupViewBinding = newValue
                return .none
                
            case .batteryStateChanged:
                autolockHandler.value(state.walletStatus == .restoring)
                return .none
                
            case .cancelAllRunningEffects:
                return .concatenate(
                    .cancel(id: CancelId),
                    .cancel(id: CancelStateId),
                    .cancel(id: CancelBatteryStateId),
                    .cancel(id: SynchronizerCancelId),
                    .cancel(id: WalletConfigCancelId),
                    .cancel(id: DidFinishLaunchingId)
                )

            default: return .none
            }
        }
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}

extension Root {
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

extension AlertState where Action == Root.Action {
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
            TextState(L10n.General.Alert.warning)
        } actions: {
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.Root.SeedPhrase.DifferentSeed.tryAgain)
            }
            ButtonState(role: .destructive, action: .initialization(.nukeWallet)) {
                TextState(L10n.General.Alert.continue)
            }
        } message: {
            TextState(L10n.Root.SeedPhrase.DifferentSeed.message)
        }
    }
    
    public static func existingWallet() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.warning)
        } actions: {
            ButtonState(role: .cancel, action: .initialization(.restoreExistingWallet)) {
                TextState(L10n.Root.ExistingWallet.restore)
            }
            ButtonState(role: .destructive, action: .initialization(.nukeWallet)) {
                TextState(L10n.General.Alert.continue)
            }
        } message: {
            TextState(L10n.Root.ExistingWallet.message)
        }
    }
    
    public static func serviceUnavailable() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.caution)
        } actions: {
            ButtonState(action: .alert(.dismiss)) {
                TextState(L10n.General.Alert.ignore)
            }
            ButtonState(action: .destination(.serverSwitch)) {
                TextState(L10n.Root.ServiceUnavailable.switchServer)
            }
        } message: {
            TextState(L10n.Root.ServiceUnavailable.message)
        }
    }
}
     
extension ConfirmationDialogState where Action == Root.Action.ConfirmationDialog {
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
