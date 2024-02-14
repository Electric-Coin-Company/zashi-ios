import SwiftUI
import ComposableArchitecture
import MessageUI

import AppVersion
import Generated
import Models
import RestoreWalletStorage
import SupportDataGenerator
import ZcashLightClientKit

public typealias SettingsStore = Store<SettingsReducer.State, SettingsReducer.Action>
public typealias SettingsViewStore = ViewStore<SettingsReducer.State, SettingsReducer.Action>

public struct SettingsReducer: Reducer {
    let network: ZcashNetwork

    public struct State: Equatable {
        public enum Destination {
            case about
            case advanced
        }

        public var advancedSettingsState: AdvancedSettingsReducer.State
        @PresentationState public var alert: AlertState<Action>?
        public var appVersion = ""
        public var appBuild = ""
        public var destination: Destination?
        public var isRestoringWallet = false
        public var supportData: SupportData?
        
        public init(
            advancedSettingsState: AdvancedSettingsReducer.State,
            appVersion: String = "",
            appBuild: String = "",
            destination: Destination? = nil,
            isRestoringWallet: Bool = false,
            supportData: SupportData? = nil
        ) {
            self.advancedSettingsState = advancedSettingsState
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.destination = destination
            self.isRestoringWallet = isRestoringWallet
            self.supportData = supportData
        }
    }

    public enum Action: Equatable {
        case advancedSettings(AdvancedSettingsReducer.Action)
        case alert(PresentationAction<Action>)
        case onAppear
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case sendSupportMail
        case sendSupportMailFinished
        case updateDestination(SettingsReducer.State.Destination?)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.restoreWalletStorage) var restoreWalletStorage

    public init(network: ZcashNetwork) {
        self.network = network
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
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

            case .advancedSettings:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)

        Scope(state: \.advancedSettingsState, action: /Action.advancedSettings) {
            AdvancedSettingsReducer(network: network)
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
    
    var bindingForAdvanced: Binding<Bool> {
        self.destinationBinding.map(
            extract: { $0 == .advanced },
            embed: { $0 ? .advanced : nil }
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
    func advancedSettingsStore() -> StoreOf<AdvancedSettingsReducer> {
        self.scope(
            state: \.advancedSettingsState,
            action: SettingsReducer.Action.advancedSettings
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
    public static let initial = SettingsReducer.State(
        advancedSettingsState: .initial
    )
}

extension SettingsStore {
    public static let placeholder = SettingsStore(
        initialState: .initial
    ) {
        SettingsReducer(network: ZcashNetworkBuilder.network(for: .testnet))
    }
    
    public static let demo = SettingsStore(
        initialState: .init(
            advancedSettingsState: .initial,
            appVersion: "0.0.1",
            appBuild: "54"
        )
    ) {
        SettingsReducer(network: ZcashNetworkBuilder.network(for: .testnet))
    }
}
