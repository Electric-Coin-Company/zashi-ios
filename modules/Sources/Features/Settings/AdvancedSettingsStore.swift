import SwiftUI
import ComposableArchitecture
import MessageUI

import Generated
import LocalAuthenticationHandler
import Models
import PrivateDataConsent
import RecoveryPhraseDisplay
import RestoreWalletStorage
import ServerSetup
import ZcashLightClientKit

public typealias AdvancedSettingsStore = Store<AdvancedSettingsReducer.State, AdvancedSettingsReducer.Action>
public typealias AdvancedSettingsViewStore = ViewStore<AdvancedSettingsReducer.State, AdvancedSettingsReducer.Action>

public struct AdvancedSettingsReducer: Reducer {
    public struct State: Equatable {
        public enum Destination {
            case backupPhrase
            case privateDataConsent
            case serverSetup
        }

        public var destination: Destination?
        public var isRestoringWallet = false
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        public var privateDataConsentState: PrivateDataConsentReducer.State
        public var serverSetupState: ServerSetup.State
        
        public init(
            destination: Destination? = nil,
            isRestoringWallet: Bool = false,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            privateDataConsentState: PrivateDataConsentReducer.State,
            serverSetupState: ServerSetup.State
        ) {
            self.destination = destination
            self.isRestoringWallet = isRestoringWallet
            self.phraseDisplayState = phraseDisplayState
            self.privateDataConsentState = privateDataConsentState
            self.serverSetupState = serverSetupState
        }
    }

    public enum Action: Equatable {
        case backupWalletAccessRequest
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case privateDataConsent(PrivateDataConsentReducer.Action)
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case serverSetup(ServerSetup.Action)
        case updateDestination(AdvancedSettingsReducer.State.Destination?)
    }

    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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

            case .updateDestination(.backupPhrase):
                state.destination = .backupPhrase
                state.phraseDisplayState.showBackButton = true
                return .none
                
            case .updateDestination(.privateDataConsent):
                state.destination = .privateDataConsent
                state.privateDataConsentState.isAcknowledged = false
                return .none

            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .restoreWalletTask:
                return .run { send in
                    for await value in await restoreWalletStorage.value() {
                            await send(.restoreWalletValue(value))
                    }
                }

            case .restoreWalletValue(let value):
                state.isRestoringWallet = value
                return .none

            case .serverSetup:
                return .none

            case .privateDataConsent(.shareFinished):
                return .none

            case .privateDataConsent:
                return .none
            }
        }

        Scope(state: \.phraseDisplayState, action: /Action.phraseDisplay) {
            RecoveryPhraseDisplay()
        }

        Scope(state: \.privateDataConsentState, action: /Action.privateDataConsent) {
            PrivateDataConsentReducer()
        }

        Scope(state: \.serverSetupState, action: /Action.serverSetup) {
            ServerSetup()
        }
    }
}

// MARK: - ViewStore

extension AdvancedSettingsViewStore {
    var destinationBinding: Binding<AdvancedSettingsReducer.State.Destination?> {
        self.binding(
            get: \.destination,
            send: AdvancedSettingsReducer.Action.updateDestination
        )
    }

    var bindingForBackupPhrase: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .backupPhrase },
            embed: { $0 ? .backupPhrase : nil }
        )
    }

    var bindingForPrivateDataConsent: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .privateDataConsent },
            embed: { $0 ? .privateDataConsent : nil }
        )
    }
    
    var bindingForServerSetup: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .serverSetup },
            embed: { $0 ? .serverSetup : nil }
        )
    }
}

// MARK: - Store

extension AdvancedSettingsStore {
    func backupPhraseStore() -> StoreOf<RecoveryPhraseDisplay> {
        self.scope(
            state: \.phraseDisplayState,
            action: AdvancedSettingsReducer.Action.phraseDisplay
        )
    }
    
    func privateDataConsentStore() -> PrivateDataConsentStore {
        self.scope(
            state: \.privateDataConsentState,
            action: AdvancedSettingsReducer.Action.privateDataConsent
        )
    }
    
    func serverSetupStore() -> StoreOf<ServerSetup> {
        self.scope(
            state: \.serverSetupState,
            action: AdvancedSettingsReducer.Action.serverSetup
        )
    }
}

// MARK: Placeholders

extension AdvancedSettingsReducer.State {
    public static let initial = AdvancedSettingsReducer.State(
        phraseDisplayState: RecoveryPhraseDisplay.State(
            phrase: nil,
            showBackButton: false,
            showCopyToBufferAlert: false,
            birthday: nil
        ),
        privateDataConsentState: .initial,
        serverSetupState: ServerSetup.State()
    )
}

extension AdvancedSettingsStore {
    public static let placeholder = AdvancedSettingsStore(
        initialState: .initial
    ) {
        AdvancedSettingsReducer()
    }
    
    public static let demo = AdvancedSettingsStore(
        initialState: .init(
            phraseDisplayState: RecoveryPhraseDisplay.State(
                phrase: nil,
                showCopyToBufferAlert: false,
                birthday: nil
            ),
            privateDataConsentState: .initial,
            serverSetupState: ServerSetup.State()
        )
    ) {
        AdvancedSettingsReducer()
    }
}
