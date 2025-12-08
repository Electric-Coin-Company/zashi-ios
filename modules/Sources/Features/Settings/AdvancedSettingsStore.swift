import SwiftUI
import ComposableArchitecture
import MessageUI

import Generated
import Models
import LocalAuthenticationHandler

@Reducer
public struct AdvancedSettings {
    @ObservableState
    public struct State: Equatable {
        public enum Operation: Equatable {
            case chooseServer
            case currencyConversion
            case disconnectHWWallet
            case exportPrivateData
            case exportTaxFile
            case recoveryPhrase
            case resetZashi
            case torSetup
        }

        public var isEnoughFreeSpaceMode = true
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

        public var isKeystoneConnected: Bool {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return true
                }
            }
            
            return false
        }

        public init() { }
    }

    public enum Action: Equatable {
        case operationAccessCheck(State.Operation)
        case operationAccessGranted(State.Operation)
    }

    @Dependency(\.localAuthentication) var localAuthentication

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .operationAccessCheck(let operation):
                switch operation {
                case .chooseServer, .currencyConversion, .torSetup:
                    return .send(.operationAccessGranted(operation))
                case .recoveryPhrase, .exportPrivateData, .exportTaxFile, .resetZashi, .disconnectHWWallet:
                    return .run { send in
                        if await localAuthentication.authenticate() {
                            await send(.operationAccessGranted(operation))
                        }
                    }
                }
                
            case .operationAccessGranted:
                return .none
            }
        }
    }
}
