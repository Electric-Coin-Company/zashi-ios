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

@Reducer
public struct Settings {
    @ObservableState
    public struct State: Equatable {
        public enum Destination {
            case about
            case advanced
        }

        public var aboutState: About.State
        public var advancedSettingsState: AdvancedSettings.State
        @Presents public var alert: AlertState<Action>?
        public var appVersion = ""
        public var appBuild = ""
        public var destination: Destination?
        public var supportData: SupportData?
        
        public init(
            aboutState: About.State,
            advancedSettingsState: AdvancedSettings.State,
            appVersion: String = "",
            appBuild: String = "",
            destination: Destination? = nil,
            supportData: SupportData? = nil
        ) {
            self.aboutState = aboutState
            self.advancedSettingsState = advancedSettingsState
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.destination = destination
            self.supportData = supportData
        }
    }

    public enum Action: Equatable {
        case about(About.Action)
        case advancedSettings(AdvancedSettings.Action)
        case alert(PresentationAction<Action>)
        case copyEmail
        case onAppear
        case sendSupportMail
        case sendSupportMailFinished
        case updateDestination(Settings.State.Destination?)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.pasteboard) var pasteboard

    public init() { }

    public var body: some Reducer<State, Action> {
        Scope(state: \.aboutState, action: \.about) {
            About()
        }

        Scope(state: \.advancedSettingsState, action: \.advancedSettings) {
            AdvancedSettings()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none
            
            case .about:
                return .none
            
            case .copyEmail:
                pasteboard.setString(SupportDataGenerator.Constants.email.redacted)
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
