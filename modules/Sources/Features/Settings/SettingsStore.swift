import SwiftUI
import ComposableArchitecture
import MessageUI

import About
import AppVersion
import Generated
import Models
import Pasteboard
import SupportDataGenerator
import ZcashLightClientKit
import AddressBook

@Reducer
public struct Settings {
    @ObservableState
    public struct State: Equatable {
        public enum Destination {
            case about
            case addressBook
            case advanced
            case integrations
        }

        public var aboutState: About.State
        public var addressBookState: AddressBook.State
        public var advancedSettingsState: AdvancedSettings.State
        @Presents public var alert: AlertState<Action>?
        public var appVersion = ""
        public var appBuild = ""
        public var destination: Destination?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var integrationsState: Integrations.State
        public var supportData: SupportData?
        
        public init(
            aboutState: About.State,
            addressBookState: AddressBook.State,
            advancedSettingsState: AdvancedSettings.State,
            appVersion: String = "",
            appBuild: String = "",
            destination: Destination? = nil,
            integrationsState: Integrations.State,
            supportData: SupportData? = nil
        ) {
            self.aboutState = aboutState
            self.addressBookState = addressBookState
            self.advancedSettingsState = advancedSettingsState
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.destination = destination
            self.integrationsState = integrationsState
            self.supportData = supportData
        }
    }

    public enum Action: Equatable {
        case about(About.Action)
        case addressBook(AddressBook.Action)
        case addressBookButtonTapped
        case advancedSettings(AdvancedSettings.Action)
        case alert(PresentationAction<Action>)
        case copyEmail
        case integrations(Integrations.Action)
        case onAppear
        case protectedAccessRequest(State.Destination)
        case sendSupportMail
        case sendSupportMailFinished
        case updateDestination(Settings.State.Destination?)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public var body: some Reducer<State, Action> {
        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }
        
        Scope(state: \.aboutState, action: \.about) {
            About()
        }

        Scope(state: \.advancedSettingsState, action: \.advancedSettings) {
            AdvancedSettings()
        }

        Scope(state: \.integrationsState, action: \.integrations) {
            Integrations()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none
            
            case .about:
                return .none
            
            case .addressBook:
                return .none
                
            case .addressBookButtonTapped:
                return .none
                
            case .copyEmail:
                pasteboard.setString(SupportDataGenerator.Constants.email.redacted)
                return .none
            
            case .integrations:
                return .none
                
            case .protectedAccessRequest(let destination):
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.updateDestination(destination))
                    }
                }

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

            case .advancedSettings:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

// MARK: Alerts

extension AlertState where Action == Settings.Action {
    public static func sendSupportMail() -> AlertState {
        AlertState {
            TextState(L10n.Settings.Alert.CantSendEmail.title)
        } actions: {
            ButtonState(action: .copyEmail) {
                TextState(L10n.Settings.Alert.CantSendEmail.copyEmail(SupportDataGenerator.Constants.email))
            }
            ButtonState(action: .sendSupportMailFinished) {
                TextState(L10n.General.close)
            }
        } message: {
            TextState(L10n.Settings.Alert.CantSendEmail.message)
        }
    }
}
