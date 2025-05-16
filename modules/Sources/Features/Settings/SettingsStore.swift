import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AppVersion
import Generated
import Models
import LocalAuthenticationHandler
import AudioServices

import About
import AddKeystoneHWWallet
import AddressBook
import CurrencyConversionSetup
import DeleteWallet
import ExportTransactionHistory
import PrivateDataConsent
import RecoveryPhraseDisplay
import Scan
import ServerSetup
import SendFeedback
import WhatsNew

@Reducer
public struct Settings {
    @Reducer
    public enum Path {
        case about(About)
        case accountHWWalletSelection(AddKeystoneHWWallet)
        case addKeystoneHWWallet(AddKeystoneHWWallet)
        case addressBook(AddressBook)
        case addressBookContact(AddressBook)
        case advancedSettings(AdvancedSettings)
        case chooseServerSetup(ServerSetup)
        case currencyConversionSetup(CurrencyConversionSetup)
        case exportPrivateData(PrivateDataConsent)
        case exportTransactionHistory(ExportTransactionHistory)
        case integrations(Integrations)
        case recoveryPhrase(RecoveryPhraseDisplay)
        case resetZashi(DeleteWallet)
        case scan(Scan)
        case sendUsFeedback(SendFeedback)
        case whatsNew(WhatsNew)
    }
    
    @ObservableState
    public struct State {
        public var appVersion = ""
        public var appBuild = ""
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isEnoughFreeSpaceMode = true
        public var path = StackState<Path.State>()
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
            selectedWalletAccount?.vendor == .keystone
        }
        
        public init() { }
    }

    public enum Action {
        case aboutTapped
        case addressBookAccessCheck
        case addressBookTapped
        case advancedSettingsTapped
        case integrationsTapped
        case onAppear
        case path(StackActionOf<Path>)
        case sendUsFeedbackTapped
        case whatsNewTapped
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.localAuthentication) var localAuthentication

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                state.path.removeAll()
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
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
