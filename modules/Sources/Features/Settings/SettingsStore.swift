import SwiftUI
import ComposableArchitecture

import AppVersion
import Generated
import Models
import LocalAuthenticationHandler

@Reducer
public struct Settings {
    @ObservableState
    public struct State: Equatable {
        public var appVersion = ""
        public var appBuild = ""
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isEnoughFreeSpaceMode = true
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

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
        
        public init() { }
    }

    public enum Action: Equatable {
        case aboutTapped
        case addressBookAccessCheck
        case addressBookTapped
        case advancedSettingsTapped
        case integrationsTapped
        case onAppear
        case sendUsFeedbackTapped
        case whatsNewTapped
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.localAuthentication) var localAuthentication

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none

            case .aboutTapped:
                return .none
                
            case .addressBookAccessCheck:
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.addressBookTapped)
                    }
                }
                
            case .addressBookTapped:
                return .none

            case .advancedSettingsTapped:
                return .none

            case .integrationsTapped:
                return .none

            case .sendUsFeedbackTapped:
                return .none

            case .whatsNewTapped:
                return .none
            }
        }
    }
}
