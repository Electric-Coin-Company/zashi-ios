import SwiftUI
import ComposableArchitecture

import Generated
import Models
import ZcashLightClientKit
import PartnerKeys
import Flexa
//import AppVersion
//import AddKeystoneHWWallet
//import Scan

@Reducer
public struct Integrations {
    @ObservableState
    public struct State: Equatable {
//        public enum StackDestinationAddKeystoneHWWallet: Int, Equatable {
//            case addKeystoneHWWallet = 0
//            case scan
//            case accountSelection
//        }

//        public var addKeystoneHWWalletState: AddKeystoneHWWallet.State = .initial
//        public var appBuild = ""
        public var appId: String?
//        public var appVersion = ""
        public var isInAppBrowserOn = false
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
//        public var scanState: Scan.State = .initial
//        public var stackDestinationAddKeystoneHWWallet: StackDestinationAddKeystoneHWWallet?
//        public var stackDestinationAddKeystoneHWWalletBindingsAlive = 0
        public var uAddress: UnifiedAddress? = nil
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

        public var isKeystoneConnected: Bool {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return true
                }
            }
            
            return false
        }
        
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
//        case addKeystoneHWWallet(AddKeystoneHWWallet.Action)
        case binding(BindingAction<Integrations.State>)
        case buyZecTapped
        case flexaTapped
        case keystoneTapped
        case onAppear
//        case scan(Scan.Action)
//        case updateStackDestinationAddKeystoneHWWallet(Integrations.State.StackDestinationAddKeystoneHWWallet?)
    }

//    @Dependency(\.appVersion) var appVersion

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

//        Scope(state: \.addKeystoneHWWalletState, action: \.addKeystoneHWWallet) {
//            AddKeystoneHWWallet()
//        }
//        
//        Scope(state: \.scanState, action: \.scan) {
//            Scan()
//        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
//                state.scanState.checkers = [.keystoneScanChecker]
                state.appId = PartnerKeys.cbProjectId
//                state.appVersion = appVersion.appVersion()
//                state.appBuild = appVersion.appBuild()
                return .none
                
            case .binding:
                return .none
                
            case .buyZecTapped:
                state.isInAppBrowserOn = true
                return .none

            case .flexaTapped:
                return .none
                
            case .keystoneTapped:
                return .none
//                return .send(.updateStackDestinationAddKeystoneHWWallet(.addKeystoneHWWallet))
                
//            case .addKeystoneHWWallet(.forgetThisDeviceTapped):
//                return .send(.updateStackDestinationAddKeystoneHWWallet(nil))
//
//            case .addKeystoneHWWallet(.continueTapped):
//                return .send(.updateStackDestinationAddKeystoneHWWallet(.scan))
//
//            case .addKeystoneHWWallet:
//                return .none
//
//            case .scan(.foundZA(let zcashAccounts)):
//                if state.addKeystoneHWWalletState.zcashAccounts == nil {
//                    state.addKeystoneHWWalletState.zcashAccounts = zcashAccounts
//                    return .send(.updateStackDestinationAddKeystoneHWWallet(.accountSelection))
//                }
//                return .none
//                
//            case .scan:
//                return .none
//
//            case .updateStackDestinationAddKeystoneHWWallet(let destination):
//                if let destination {
//                    state.stackDestinationAddKeystoneHWWalletBindingsAlive = destination.rawValue
//                }
//                state.stackDestinationAddKeystoneHWWallet = destination
//                return .none
            }
        }
    }
}
