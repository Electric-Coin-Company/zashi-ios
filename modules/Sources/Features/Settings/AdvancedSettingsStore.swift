import SwiftUI
import ComposableArchitecture
import MessageUI

import DeleteWallet
import Generated
import LocalAuthenticationHandler
import Models
import PrivateDataConsent
import RecoveryPhraseDisplay
import ServerSetup
import ZcashLightClientKit
import PartnerKeys

@Reducer
public struct AdvancedSettings {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case backupPhrase
            case deleteWallet
            case privateDataConsent
            case serverSetup
        }

        public var appId: String?
        public var deleteWallet: DeleteWallet.State
        public var destination: Destination?
        public var isInAppBrowserOn = false
        public var phraseDisplayState: RecoveryPhraseDisplay.State
        public var privateDataConsentState: PrivateDataConsentReducer.State
        public var serverSetupState: ServerSetup.State
        public var uAddress: UnifiedAddress? = nil
        
        public var inAppBrowserURL: String? {
            if let address = try? uAddress?.transparentReceiver().stringEncoded, let appId {
                return L10n.Partners.coinbaseOnrampUrl(appId, address)
            }
            
            return nil
        }
        
        public init(
            deleteWallet: DeleteWallet.State,
            destination: Destination? = nil,
            isInAppBrowserOn: Bool = false,
            phraseDisplayState: RecoveryPhraseDisplay.State,
            privateDataConsentState: PrivateDataConsentReducer.State,
            serverSetupState: ServerSetup.State,
            uAddress: UnifiedAddress? = nil
        ) {
            self.deleteWallet = deleteWallet
            self.destination = destination
            self.isInAppBrowserOn = isInAppBrowserOn
            self.phraseDisplayState = phraseDisplayState
            self.privateDataConsentState = privateDataConsentState
            self.serverSetupState = serverSetupState
            self.uAddress = uAddress
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<AdvancedSettings.State>)
        case buyZecTapped
        case deleteWallet(DeleteWallet.Action)
        case onAppear
        case phraseDisplay(RecoveryPhraseDisplay.Action)
        case privateDataConsent(PrivateDataConsentReducer.Action)
        case protectedAccessRequest(State.Destination)
        case serverSetup(ServerSetup.Action)
        case updateDestination(AdvancedSettings.State.Destination?)
    }

    @Dependency(\.localAuthentication) var localAuthentication

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appId = PartnerKeys.cbProjectId
                return .none
                
            case .binding:
                return .none
                
            case .buyZecTapped:
                state.isInAppBrowserOn = true
                return .none
                
            case .protectedAccessRequest(let destination):
                return .run { send in
                    if await localAuthentication.authenticate() {
                        await send(.updateDestination(destination))
                    }
                }
            
            case .deleteWallet:
                return .none
                
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

        Scope(state: \.deleteWallet, action: /Action.deleteWallet) {
            DeleteWallet()
        }
    }
}

