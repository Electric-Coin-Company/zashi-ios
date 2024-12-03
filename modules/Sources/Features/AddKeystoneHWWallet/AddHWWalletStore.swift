//
//  AddKeystoneHWWalletStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-26.
//

import SwiftUI
import ComposableArchitecture
import Generated
import KeystoneSDK
import Models

@Reducer
public struct AddKeystoneHWWallet {
    @ObservableState
    public struct State: Equatable {
        public var isKSAccountSelected = false
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount = .default
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = [.default]
        public var zcashAccounts: ZcashAccounts?

        public var keystoneAddress: String {
            if let _ = zcashAccounts?.accounts.first {
                return "0x7F...EE2d"
            }
            
            return ""
        }
        
        public init(
        ) {
        }
    }

    public enum Action: BindableAction, Equatable {
        case accountTapped
        case binding(BindingAction<AddKeystoneHWWallet.State>)
        case continueTapped
        case forgetThisDeviceTapped
        case onAppear
        case unlockTapped
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isKSAccountSelected = false
                state.zcashAccounts = nil
                return .none
            
            case .binding:
                return .none
                
            case .accountTapped:
                state.isKSAccountSelected.toggle()
                return .none
                
            case .forgetThisDeviceTapped:
                return .none

            case .unlockTapped:
                // TODO: mocked here until SDK side is ready
                state.walletAccounts.append(
                    WalletAccount(
                        id: "1",
                        vendor: .keystone,
                        uaAddressString: "0x8EgiqpBzgfeFqB6cde..."
                    )
                )
                state.selectedWalletAccount = state.walletAccounts.last ?? .default
                return .send(.forgetThisDeviceTapped)

            case .continueTapped:
                return .none
            }
        }
    }
}
