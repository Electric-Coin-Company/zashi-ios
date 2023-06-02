import ComposableArchitecture
import MessageUI
import SwiftUI
import AppVersion
import MnemonicClient
import LogsHandler
import LocalAuthenticationHandler
import SupportDataGenerator
import Models
import RecoveryPhraseDisplay
import ZcashLightClientKit
import Generated

typealias SettingsStore = Store<SettingsReducer.State, SettingsReducer.Action>
typealias SettingsViewStore = ViewStore<SettingsReducer.State, SettingsReducer.Action>

struct SettingsReducer: ReducerProtocol {
    struct State: Equatable {
        enum Destination {
            case about
            case backupPhrase
        }

        @PresentationState var alert: AlertState<Action>?
        var appVersion = ""
        var appBuild = ""
        var destination: Destination?
        var exportLogsState: ExportLogsReducer.State
        @BindingState var isCrashReportingOn: Bool
        var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        var supportData: SupportData?
    }

    enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case backupWallet
        case backupWalletAccessRequest
        case binding(BindingAction<SettingsReducer.State>)
        case exportLogs(ExportLogsReducer.Action)
        case onAppear
        case phraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case sendSupportMail
        case sendSupportMailFinished
        case updateDestination(SettingsReducer.State.Destination?)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.logsHandler) var logsHandler
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.userStoredPreferences) var userStoredPreferences
    @Dependency(\.crashReporter) var crashReporter

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isCrashReportingOn = !userStoredPreferences.isUserOptedOutOfCrashReporting()
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none
            case .backupWalletAccessRequest:
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.backupWallet)
                    }
                }
                
            case .backupWallet:
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    let phraseWords = mnemonic.asWords(storedWallet.seedPhrase.value())
                    let recoveryPhrase = RecoveryPhrase(words: phraseWords.map { $0.redacted })
                    state.phraseDisplayState.phrase = recoveryPhrase
                    return EffectTask(value: .updateDestination(.backupPhrase))
                } catch {
                    state.alert = AlertState.cantBackupWallet(error.toZcashError())
                }
                return .none
                
            case .binding(\.$isCrashReportingOn):
                if state.isCrashReportingOn {
                    crashReporter.optOut()
                } else {
                    crashReporter.optIn()
                }

                return .run { [state] _ in
                    await userStoredPreferences.setIsUserOptedOutOfCrashReporting(state.isCrashReportingOn)
                }
                
            case .exportLogs:
                return .none

            case .phraseDisplay:
                state.destination = nil
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .binding:
                return .none

            case .sendSupportMail:
                if MFMailComposeViewController.canSendMail() {
                    state.supportData = SupportDataGenerator.generate()
                } else {
                    state.alert = AlertState.sendSupportMail()
                }
                return .none

            case .sendSupportMailFinished:
                state.supportData = nil
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)

        Scope(state: \.phraseDisplayState, action: /Action.phraseDisplay) {
            RecoveryPhraseDisplayReducer()
        }

        Scope(state: \.exportLogsState, action: /Action.exportLogs) {
            ExportLogsReducer()
        }
    }
}

// MARK: - ViewStore

extension SettingsViewStore {
    var destinationBinding: Binding<SettingsReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: SettingsReducer.Action.updateDestination
        )
    }
    
    var bindingForBackupPhrase: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .backupPhrase },
            embed: { $0 ? .backupPhrase : nil }
        )
    }
    
    var bindingForAbout: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .about },
            embed: { $0 ? .about : nil }
        )
    }
}

// MARK: - Store

extension SettingsStore {
    func backupPhraseStore() -> RecoveryPhraseDisplayStore {
        self.scope(
            state: \.phraseDisplayState,
            action: SettingsReducer.Action.phraseDisplay
        )
    }
}

// MARK: Alerts

extension AlertState where Action == SettingsReducer.Action {
    static func cantBackupWallet(_ error: ZcashError) -> AlertState<SettingsReducer.Action> {
        AlertState<SettingsReducer.Action> {
            TextState(L10n.Settings.Alert.CantBackupWallet.title)
        } message: {
            TextState(L10n.Settings.Alert.CantBackupWallet.message(error.message, error.code.rawValue))
        }
    }
    
    static func sendSupportMail() -> AlertState<SettingsReducer.Action> {
        AlertState<SettingsReducer.Action> {
            TextState(L10n.Settings.Alert.CantSendEmail.title)
        } actions: {
            ButtonState(action: .sendSupportMailFinished) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.Settings.Alert.CantSendEmail.message)
        }
    }
}

// MARK: Placeholders

extension SettingsReducer.State {
    static let placeholder = SettingsReducer.State(
        exportLogsState: .placeholder,
        isCrashReportingOn: true,
        phraseDisplayState: RecoveryPhraseDisplayReducer.State(
            phrase: .placeholder
        )
    )
}

extension SettingsStore {
    static let placeholder = SettingsStore(
        initialState: .placeholder,
        reducer: SettingsReducer()
    )
}
