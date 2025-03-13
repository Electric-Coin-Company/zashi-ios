import SwiftUI
import ComposableArchitecture

import AppVersion
import Generated
import Models
import LocalAuthenticationHandler

import About
import AddKeystoneHWWallet
import AddressBook
import ServerSetup
import CurrencyConversionSetup
import PrivateDataConsent
import ExportTransactionHistory
import DeleteWallet
import Scan
import SendFeedback
import WhatsNew

import Utils

@Reducer
public struct Settings {
//    @Reducer
//    public enum Path {
//        case about(About)
//        case accountHWWalletSelection(AddKeystoneHWWallet)
//        case addKeystoneHWWallet(AddKeystoneHWWallet)
//        case addressBook(AddressBook)
//        case addressBookContact(AddressBook)
//        case advancedSettings(AdvancedSettings)
//        case chooseServerSetup(ServerSetup)
//        case currencyConversionSetup(CurrencyConversionSetup)
//        case exportPrivateData(PrivateDataConsent)
//        case exportTransactionHistory(ExportTransactionHistory)
//        case integrations(Integrations)
//        case resetZashi(DeleteWallet)
//        case scan(Scan)
//        case sendUsFeedback(SendFeedback)
//        case whatsNew(WhatsNew)
//    }
    
    @ObservableState
    public struct State: Equatable {
        @CoW public var test = ""
        public var appVersion = ""
        public var appBuild = ""
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isEnoughFreeSpaceMode = true
//        public var path = StackState<Path.State>()
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
//        case path(StackActionOf<Path>)
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
                
//            case .path:
//                return .none
            }
        }
//        .forEach(\.path, action: \.path)
    }
}
