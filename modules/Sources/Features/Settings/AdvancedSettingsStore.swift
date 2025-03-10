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
            case exportPrivateData
            case exportTaxFile
            case recoveryPhrase
            case resetZashi
        }
        
        public var isEnoughFreeSpaceMode = true
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []

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
                case .chooseServer, .currencyConversion:
                    return .send(.operationAccessGranted(operation))
                case .recoveryPhrase, .exportPrivateData, .exportTaxFile, .resetZashi:
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
