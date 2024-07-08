import SwiftUI
import ComposableArchitecture

import Generated
import Models
import ZcashLightClientKit
import PartnerKeys
import Flexa
import AppVersion

@Reducer
public struct Integrations {
    @ObservableState
    public struct State: Equatable {
        public var appBuild = ""
        public var appId: String?
        public var appVersion = ""
        public var isFlexaOn = false
        public var isInAppBrowserOn = false
        public var uAddress: UnifiedAddress? = nil
        
        public var inAppBrowserURL: String? {
            if let address = try? uAddress?.transparentReceiver().stringEncoded, let appId {
                return L10n.Partners.coinbaseOnrampUrl(appId, address)
            }
            
            return nil
        }
        
        public init(
            isInAppBrowserOn: Bool = false,
            uAddress: UnifiedAddress? = nil
        ) {
            self.isInAppBrowserOn = isInAppBrowserOn
            self.uAddress = uAddress
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<Integrations.State>)
        case buyZecTapped
        case flexaTapped
        case onAppear
    }

    @Dependency(\.appVersion) var appVersion

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appId = PartnerKeys.cbProjectId
                state.appVersion = appVersion.appVersion()
                state.appBuild = appVersion.appBuild()
                return .none
                
            case .binding:
                return .none
                
            case .buyZecTapped:
                state.isInAppBrowserOn = true
                return .none

            case .flexaTapped:
                return .none
            }
        }
    }
}
