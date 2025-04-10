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
import ReadTransactionsStorage
import BackgroundTasks
import Utils
import UserDefaults
import ExchangeRate
import FlexaHandler
import Flexa
import AutolockHandler
import UIComponents
import LocalAuthenticationHandler
import DeeplinkWarning
import URIParser
import OSStatusError
import AddressBookClient
import UserMetadataProvider
import AudioServices

// Screens
//import About
//import AddKeystoneHWWallet
//import AddressBook
//import AddressDetails
import CurrencyConversionSetup
//import DeleteWallet
//import ExportTransactionHistory
import Home
//import PartialProposalError
//import PrivateDataConsent
import Receive
import RecoveryPhraseDisplay
import CoordFlows
//import RequestZec
//import Scan
//import SendConfirmation
//import SendFeedback
//import SendForm
import ServerSetup
import Settings
//import TransactionDetails
//import TransactionsManager
//import WhatsNew
//import ZecKeyboard

@Reducer
public struct Root {
    public enum ResetZashiConstants {
        static let maxResetZashiAppAttempts = 3
        static let maxResetZashiSDKAttempts = 3
    }
    
//    @Reducer
//    public enum Path {
//            case about(About)
//            case accountHWWalletSelection(AddKeystoneHWWallet)
//            case addKeystoneHWWallet(AddKeystoneHWWallet)
//            case addressBook(AddressBook)
//            case addressBookContact(AddressBook)
//        case addressDetails(AddressDetails)
//            case advancedSettings(AdvancedSettings)
//            case chooseServerSetup(ServerSetup)
//            case currencyConversionSetup(CurrencyConversionSetup)
//            case exportPrivateData(PrivateDataConsent)
//            case exportTransactionHistory(ExportTransactionHistory)
//            case integrations(Integrations)
////        case preSendingFailure(SendConfirmation)
//        case receive(Receive)
//        case recoveryPhrase(RecoveryPhraseDisplay)
//        case requestZec(RequestZec)
////        case requestZecConfirmation(SendConfirmation)
//        case requestZecSummary(RequestZec)
//            case resetZashi(DeleteWallet)
//        case scan(Scan)
//        case sendConfirmation(SendConfirmation)
//        case sendForm(SendForm)
//        case sending(SendConfirmation)
//        case sendResultFailure(SendConfirmation)
//        case sendResultPartial(PartialProposalError)
//        case sendResultResubmission(SendConfirmation)
//        case sendResultSuccess(SendConfirmation)
//            case sendUsFeedback(SendFeedback)
//        case settings(Settings)
//        case transactionDetails(TransactionDetails)
//        case transactionsManager(TransactionsManager)
//            case whatsNew(WhatsNew)
//        case zecKeyboard(ZecKeyboard)
//    }

    let CancelId = UUID()
    let CancelStateId = UUID()
    let CancelBatteryStateId = UUID()
    let SynchronizerCancelId = UUID()
    let WalletConfigCancelId = UUID()
    let DidFinishLaunchingId = UUID()
    let CancelFlexaId = UUID()

    @ObservableState
    public struct State {
        public enum Path {
            case addKeystoneHWWalletCoordFlow
            case currencyConversionSetup
            case receive
            case requestZecCoordFlow
            case scanCoordFlow
            case sendCoordFlow
            case settings
            case signWithKeystoneCoordFlow
            case transactionsCoordFlow
        }
        
        public var CancelEventId = UUID()
        public var CancelStateId = UUID()

        //        public var addressBookBinding: Bool = false
//        public var addressBookContactBinding: Bool = false
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
//        public var addressBookState: AddressBook.State
        @Presents public var alert: AlertState<Action>?
        public var appInitializationState: InitializationState = .uninitialized
        public var appStartState: AppStartState = .unknown
        public var bgTask: BGProcessingTask?
        @Presents public var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
        public var debugState: DebugState
        public var deeplinkWarningState: DeeplinkWarning.State = .initial
        public var destinationState: DestinationState
        public var exportLogsState: ExportLogs.State
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var homeState: Home.State = .initial
        public var isLockedInKeychainUnavailableState = false
        public var isRestoringWallet = false
        @Shared(.appStorage(.lastAuthenticationTimestamp)) public var lastAuthenticationTimestamp: Int = 0
        public var maxResetZashiAppAttempts = ResetZashiConstants.maxResetZashiAppAttempts
        public var maxResetZashiSDKAttempts = ResetZashiConstants.maxResetZashiSDKAttempts
        public var notEnoughFreeSpaceState: NotEnoughFreeSpace.State
        public var onboardingState: OnboardingFlow.State
        public var osStatusErrorState: OSStatusError.State
//        public var path = StackState<Path.State>()
        public var path: Path? = nil
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var serverSetupState: ServerSetup.State
        public var serverSetupViewBinding = false
        public var splashAppeared = false
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        @Shared(.inMemory(.transactionMemos)) public var transactionMemos: [String: [String]] = [:]
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        public var walletConfig: WalletConfig
        @Shared(.inMemory(.walletStatus)) public var walletStatus: WalletStatus = .none
        public var wasRestoringWhenDisconnected = false
        public var welcomeState: Welcome.State
        public var zashiUAddress: UnifiedAddress? = nil
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        // Path
        public var addKeystoneHWWalletCoordFlowState = AddKeystoneHWWalletCoordFlow.State.initial
        public var currencyConversionSetupState = CurrencyConversionSetup.State.initial
        public var receiveState = Receive.State.initial
        public var requestZecCoordFlowState = RequestZecCoordFlow.State.initial
        public var scanCoordFlowState = ScanCoordFlow.State.initial
        public var sendCoordFlowState = SendCoordFlow.State.initial
        public var settingsState = Settings.State.initial
        public var signWithKeystoneCoordFlowState = SignWithKeystoneCoordFlow.State.initial
        public var transactionsCoordFlowState = TransactionsCoordFlow.State.initial

        //public var requestZecState = RequestZec.State.initial

        public init(
//            addressBookState: AddressBook.State = .initial,
            appInitializationState: InitializationState = .uninitialized,
            appStartState: AppStartState = .unknown,
            debugState: DebugState,
            destinationState: DestinationState,
            exportLogsState: ExportLogs.State,
            isLockedInKeychainUnavailableState: Bool = false,
            isRestoringWallet: Bool = false,
            notEnoughFreeSpaceState: NotEnoughFreeSpace.State = .initial,
            onboardingState: OnboardingFlow.State,
            osStatusErrorState: OSStatusError.State = .initial,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            serverSetupState: ServerSetup.State = .initial,
            walletConfig: WalletConfig,
            welcomeState: Welcome.State
        ) {
//            self.addressBookState = addressBookState
            self.appInitializationState = appInitializationState
            self.appStartState = appStartState
            self.debugState = debugState
            self.destinationState = destinationState
            self.exportLogsState = exportLogsState
            self.isLockedInKeychainUnavailableState = isLockedInKeychainUnavailableState
            self.isRestoringWallet = isRestoringWallet
            self.onboardingState = onboardingState
            self.osStatusErrorState = osStatusErrorState
            self.notEnoughFreeSpaceState = notEnoughFreeSpaceState
            self.phraseDisplayState = phraseDisplayState
            self.serverSetupState = serverSetupState
            self.walletConfig = walletConfig
            self.welcomeState = welcomeState
        }
    }

    public enum Action: BindableAction {
        public enum ConfirmationDialog: Equatable {
            case fullRescan
            case quickRescan
        }

        //        case addressBook(AddressBook.Action)
//        case addressBookBinding(Bool)
//        case addressBookContactBinding(Bool)
//        case addressBookAccessGranted
        case alert(PresentationAction<Action>)
        case batteryStateChanged(Notification?)
        case binding(BindingAction<Root.State>)
        case cancelAllRunningEffects
        case confirmationDialog(PresentationAction<ConfirmationDialog>)
        case debug(DebugAction)
        case deeplinkWarning(DeeplinkWarning.Action)
        case destination(DestinationAction)
        case exportLogs(ExportLogs.Action)
        case flexaOnTransactionRequest(FlexaTransaction?)
        case flexaOpenRequest
        case flexaTransactionFailed(String)
        case home(Home.Action)
        case initialization(InitializationAction)
        case notEnoughFreeSpace(NotEnoughFreeSpace.Action)
//        case path(StackActionOf<Path>)
        case resetZashiFinishProcessing
        case resetZashiKeychainFailed(OSStatus)
        case resetZashiKeychainFailedWithCorruptedData(String)
        case resetZashiKeychainRequest
        case resetZashiSDKFailed
        case resetZashiSDKSucceeded
        case onboarding(OnboardingFlow.Action)
        case osStatusError(OSStatusError.Action)
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case splashFinished
        case splashRemovalRequested
        case serverSetup(ServerSetup.Action)
        case serverSetupBindingUpdated(Bool)
        case synchronizerStateChanged(RedactableSynchronizerState)
        case transactionDetailsOpen(String)
        case updateStateAfterConfigUpdate(WalletConfig)
        case walletConfigLoaded(WalletConfig)
        case welcome(Welcome.Action)
        
        // Path
        case addKeystoneHWWalletCoordFlow(AddKeystoneHWWalletCoordFlow.Action)
        case currencyConversionSetup(CurrencyConversionSetup.Action)
        case receive(Receive.Action)
        case requestZecCoordFlow(RequestZecCoordFlow.Action)
        case scanCoordFlow(ScanCoordFlow.Action)
        case sendAgainRequested(TransactionState)
        case sendCoordFlow(SendCoordFlow.Action)
        case settings(Settings.Action)
        case signWithKeystoneCoordFlow(SignWithKeystoneCoordFlow.Action)
        case signWithKeystoneRequested
        case transactionsCoordFlow(TransactionsCoordFlow.Action)

        // Transactions
        case observeTransactions
        case foundTransactions([ZcashTransaction.Overview])
        case minedTransaction(ZcashTransaction.Overview)
        case fetchTransactionsForTheSelectedAccount
        case fetchedTransactions([TransactionState])
        case noChangeInTransactions
        
        // Address Book
        case loadContacts
        case contactsLoaded(AddressBookContacts)
        
        // UserMetadata
        case loadUserMetadata
        case resolveMetadataEncryptionKeys
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.autolockHandler) var autolockHandler
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
    @Dependency(\.userMetadataProvider) var userMetadataProvider
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.walletConfigProvider) var walletConfigProvider
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.readTransactionsStorage) var readTransactionsStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.deeplinkWarningState, action: \.deeplinkWarning) {
            DeeplinkWarning()
        }
        
//        Scope(state: \.addressBookState, action: \.addressBook) {
//            AddressBook()
//        }
        
        Scope(state: \.serverSetupState, action: \.serverSetup) {
            ServerSetup()
        }

        Scope(state: \.homeState, action: \.home) {
            Home()
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

        Scope(state: \.welcomeState, action: \.welcome) {
            Welcome()
        }

        Scope(state: \.phraseDisplayState, action: \.phraseDisplay) {
            RecoveryPhraseDisplay()
        }

        Scope(state: \.osStatusErrorState, action: \.osStatusError) {
            OSStatusError()
        }

        Scope(state: \.settingsState, action: \.settings) {
            Settings()
        }

        Scope(state: \.receiveState, action: \.receive) {
            Receive()
        }
        
        Scope(state: \.requestZecCoordFlowState, action: \.requestZecCoordFlow) {
            RequestZecCoordFlow()
        }
        
        Scope(state: \.sendCoordFlowState, action: \.sendCoordFlow) {
            SendCoordFlow()
        }
        
        Scope(state: \.scanCoordFlowState, action: \.scanCoordFlow) {
            ScanCoordFlow()
        }
        
        Scope(state: \.addKeystoneHWWalletCoordFlowState, action: \.addKeystoneHWWalletCoordFlow) {
            AddKeystoneHWWalletCoordFlow()
        }

        Scope(state: \.transactionsCoordFlowState, action: \.transactionsCoordFlow) {
            TransactionsCoordFlow()
        }

        Scope(state: \.currencyConversionSetupState, action: \.currencyConversionSetup) {
            CurrencyConversionSetup()
        }

        Scope(state: \.signWithKeystoneCoordFlowState, action: \.signWithKeystoneCoordFlow) {
            SignWithKeystoneCoordFlow()
        }

        initializationReduce()

        destinationReduce()
        
        debugReduce()
        
        transactionsReduce()
        
        addressBookReduce()
        
        userMetadataReduce()
        
        coordinatorReduce()
    }
    
    public var body: some Reducer<State, Action> {
        self.core

        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none
            
//            case .addressBookBinding(let newValue):
//                state.addressBookBinding = newValue
//                return .none
//
//            case .addressBookContactBinding(let newValue):
//                state.addressBookContactBinding = newValue
//                return .none

//            case .tabs(.send(.addNewContactTapped(let address))):
//                state.addressBookContactBinding = true
//                state.addressBookState.isValidZcashAddress = true
//                state.addressBookState.isNameFocused = true
//                state.addressBookState.address = address.data
//                return .none
                
//            case .addressBook(.saveButtonTapped):
////                if state.addressBookBinding {
////                    state.addressBookBinding = false
////                }
//                if state.addressBookContactBinding {
//                    state.addressBookContactBinding = false
//                }
//                return .none

//            case .addressBookAccessGranted:
//                state.addressBookBinding = true
//                state.addressBookState.isInSelectMode = true
//                return .none

            //case .tabs(.send(.addressBookTapped)):
//            case .tabs(.path(.element(id: _, action: .sendFlow(.addressBookTapped)))):
//                return .run { send in
//                    if await !localAuthentication.authenticate() {
//                        return
//                    }
//                    await send(.addressBookAccessGranted)
//                }

//            case .addressBook(.walletAccountTapped(let walletAccount)):
//                guard let address = walletAccount.uAddress?.stringEncoded else {
//                    return .none
//                }
//                state.addressBookBinding = false
////                return .send(.tabs(.send(.scan(.found(address.redacted)))))
//                return .none
//
//            case .addressBook(.editId(let address)):
//                state.addressBookBinding = false
//                guard let first = state.tabsState.path.ids.first else {
//                    return .none
//                }
//                return .send(.tabs(.path(.element(id: first, action: .sendFlow(.addressUpdated(address.redacted))))))
//                return .send(.tabs(.path(.element(id: first, action: .sendFlow(.scan(.found(address.redacted)))))))
//                for (_, element) in zip(state.path.ids, state.path) {
//                    switch element {
//                    case .sendFlow(let sendState):
//                    }
//                }
                //return .send(.tabs(.send(.scan(.found(address.redacted)))))
                //return
//                return .none
            
            case .serverSetup:
                return .none
                
            case .serverSetupBindingUpdated(let newValue):
                state.serverSetupViewBinding = newValue
                return .none
                
            case .batteryStateChanged:
                let leavesScreenOpen = userDefaults.objectForKey(Constants.udLeavesScreenOpen) as? Bool ?? false
                autolockHandler.value(state.walletStatus == .restoring && leavesScreenOpen)
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

            case .onboarding(.newWalletSuccessfulyCreated):
                return .send(.initialization(.initializeSDK(.newWallet)))

            default: return .none
            }
        }
        //.forEach(\.path, action: \.path)
        //.ifLet(\.$confirmationDialog, action: \.confirmationDialog)
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
        } catch WalletStorage.KeychainError.unknown(let osStatus) {
            return .osStatus(osStatus)
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
        } actions: {
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.Settings.deleteZashi)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.Root.Initialization.Alert.WalletStateFailed.message(walletState))
        }
    }
    
    public static func wipeFailed(_ osStatus: OSStatus) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.WipeFailed.title)
        } message: {
            TextState("OSStatus: \(osStatus), \(L10n.Root.Initialization.Alert.WipeFailed.message)")
        }
    }
    
    public static func wipeKeychainFailed(_ errMsg: String) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.WipeFailed.title)
        } message: {
            TextState("Keychain failed: \(errMsg)")
        }
    }
    
    public static func wipeRequest() -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Wipe.title)
        } actions: {
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
                TextState(L10n.General.yes)
            }
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.General.no)
            }
        } message: {
            TextState(L10n.Root.Initialization.Alert.Wipe.message)
        }
    }

    public static func differentSeed() -> AlertState {
        AlertState {
            TextState(L10n.General.Alert.warning)
        } actions: {
            ButtonState(role: .cancel, action: .alert(.dismiss)) {
                TextState(L10n.Root.SeedPhrase.DifferentSeed.tryAgain)
            }
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
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
            ButtonState(role: .destructive, action: .initialization(.resetZashi)) {
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
