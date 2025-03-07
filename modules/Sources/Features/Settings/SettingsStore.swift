import SwiftUI
import ComposableArchitecture

import About
import AppVersion
import Generated
import Models
import ZcashLightClientKit
import AddressBook
import WhatsNew
import SendFeedback
import SupportDataGenerator

@Reducer
public struct Settings {
    @ObservableState
    public struct State: Equatable {
        public enum Destination {
            case about
            case addressBook
            case advanced
            case integrations
            case sendFeedback
            case whatsNew
        }

        public var aboutState: About.State
        public var addressBookState: AddressBook.State
        public var advancedSettingsState: AdvancedSettings.State
        public var appVersion = ""
        public var appBuild = ""
        public var destination: Destination?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var integrationsState: Integrations.State
        public var isEnoughFreeSpaceMode = true
        public var supportData: SupportData?
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var sendFeedbackState: SendFeedback.State = .initial
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        public var whatsNewState: WhatsNew.State = .initial

        public var isKeystoneConnected: Bool {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return true
                }
            }
            
            return false
        }

        public var isKeystoneAccount: Bool {
            selectedWalletAccount?.vendor == .keystone ? true : false
        }
        
        public init(
            aboutState: About.State,
            addressBookState: AddressBook.State,
            advancedSettingsState: AdvancedSettings.State,
            appVersion: String = "",
            appBuild: String = "",
            destination: Destination? = nil,
            integrationsState: Integrations.State
        ) {
            self.aboutState = aboutState
            self.addressBookState = addressBookState
            self.advancedSettingsState = advancedSettingsState
            self.appVersion = appVersion
            self.appBuild = appBuild
            self.destination = destination
            self.integrationsState = integrationsState
        }
    }

    public enum Action: Equatable {
        case about(About.Action)
        case addressBook(AddressBook.Action)
        case addressBookButtonTapped
        case advancedSettings(AdvancedSettings.Action)
        case integrations(Integrations.Action)
        case onAppear
        case protectedAccessRequest(State.Destination)
        case sendFeedback(SendFeedback.Action)
        case updateDestination(Settings.State.Destination?)
        case whatsNew(WhatsNew.Action)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.localAuthentication) var localAuthentication

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

        Scope(state: \.sendFeedbackState, action: \.sendFeedback) {
            SendFeedback()
        }

        Scope(state: \.whatsNewState, action: \.whatsNew) {
            WhatsNew()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                state.advancedSettingsState.isEnoughFreeSpaceMode = state.isEnoughFreeSpaceMode
                return .none
            
            case .about:
                return .none
            
            case .addressBook:
                return .none
                
            case .addressBookButtonTapped:
                return .none
                
            case .integrations:
                return .none
                
            case .sendFeedback:
                return .none
                
            case .whatsNew:
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

            case .advancedSettings:
                return .none
            }
        }
    }
}
