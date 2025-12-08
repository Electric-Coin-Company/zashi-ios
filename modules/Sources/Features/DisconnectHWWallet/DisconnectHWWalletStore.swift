//
//  DisconnectHWWalletStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 12-08-2025
//

import ComposableArchitecture

import Generated
import SDKSynchronizer
import Utils
import ZcashLightClientKit
import Models

@Reducer
public struct DisconnectHWWallet {
    @ObservableState
    public struct State: Equatable {
        public var isAreYouSureSheetPresented = false
        public var isProcessing = false
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        
        public var keystoneAccountUUID: AccountUUID? {
            for account in walletAccounts {
                if account.vendor == .keystone {
                    return account.id
                }
            }
            
            return nil
        }
        
        public init() {}
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<DisconnectHWWallet.State>)
        case disconnectCanceled
        case disconnectDevice
        case disconnectFailed
        case disconnectRequested
        case disconnectSucceeded([WalletAccount])
    }

    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .disconnectCanceled:
                state.isAreYouSureSheetPresented = false
                return .none

            case .disconnectDevice:
                guard let accountUUID = state.keystoneAccountUUID else {
                    return .none
                }
                state.isAreYouSureSheetPresented = false
                state.isProcessing = true
                return .run { send in
                    do {
                        try await sdkSynchronizer.deleteAccount(accountUUID)
                        let walletAccounts = try await sdkSynchronizer.walletAccounts()
                        await send(.disconnectSucceeded(walletAccounts))
                    } catch {
                        await send(.disconnectFailed)
                    }
                }

            case .disconnectRequested:
                state.isAreYouSureSheetPresented = true
                return .none

            case .disconnectFailed:
                state.isProcessing = false
                return .none

            case .disconnectSucceeded:
                state.isProcessing = false
                return .none
            }
        }
    }
}
