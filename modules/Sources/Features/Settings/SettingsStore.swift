import ComposableArchitecture
import MessageUI
import SwiftUI
import AppVersion
import MnemonicClient
import LocalAuthenticationHandler
import SupportDataGenerator
import Models
import RecoveryPhraseDisplay
import ZcashLightClientKit
import Generated
import WalletStorage
import SDKSynchronizer

public typealias SettingsStore = Store<SettingsReducer.State, SettingsReducer.Action>
public typealias SettingsViewStore = ViewStore<SettingsReducer.State, SettingsReducer.Action>

public struct SettingsReducer: ReducerProtocol {
    public struct State: Equatable {
        public enum Destination {
            case about
            case backupPhrase
        }

        @PresentationState public var alert: AlertState<Action>?
        public var appVersion = ""
        public var appBuild = ""
        public var destination: Destination?
        public var phraseDisplayState: RecoveryPhraseDisplayReducer.State
        public var supportData: SupportData?
        
        public init(
            appVersion: String = "",
            appBuild: String = "",
            destination: Destination? = nil,
            phraseDisplayState: RecoveryPhraseDisplayReducer.State,
            supportData: SupportData? = nil
        ) {
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.destination = destination
            self.phraseDisplayState = phraseDisplayState
            self.supportData = supportData
        }
    }

    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case backupWalletAccessRequest
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
    @Dependency(\.walletStorage) var walletStorage

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none
            case .backupWalletAccessRequest:
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.updateDestination(.backupPhrase))
                    }
                }
                                
            case .phraseDisplay(.finishedPressed):
                state.destination = nil
                return .none
                                
            case .phraseDisplay:
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
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
                
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)

        Scope(state: \.phraseDisplayState, action: /Action.phraseDisplay) {
            RecoveryPhraseDisplayReducer()
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
    public static func sendSupportMail() -> AlertState {
        AlertState {
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
    public static let placeholder = SettingsReducer.State(
        phraseDisplayState: RecoveryPhraseDisplayReducer.State(
            phrase: nil,
            showCopyToBufferAlert: false,
            birthday: nil
        )
    )
}

extension SettingsStore {
    public static let placeholder = SettingsStore(
        initialState: .placeholder,
        reducer: SettingsReducer()
    )
    
    public static let demo = SettingsStore(
        initialState: .init(
            appVersion: "0.0.1",
            appBuild: "54",
            phraseDisplayState: RecoveryPhraseDisplayReducer.State(
                phrase: nil,
                showCopyToBufferAlert: false,
                birthday: nil
            )
        ),
        reducer: SettingsReducer()
    )
}
