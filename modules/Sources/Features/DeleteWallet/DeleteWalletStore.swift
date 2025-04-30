//
//  DeleteWalletStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-27-2024
//

import ComposableArchitecture

import Generated
import SDKSynchronizer
import Utils
import ZcashLightClientKit

@Reducer
public struct DeleteWallet {
    @ObservableState
    public struct State: Equatable {
        public var isAcknowledged: Bool = false
        public var isProcessing: Bool = false

        public init(
            isAcknowledged: Bool = false,
            isProcessing: Bool = false
        ) {
            self.isAcknowledged = isAcknowledged
            self.isProcessing = isProcessing
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<DeleteWallet.State>)
        case deleteTapped
        case deleteCanceled
    }

    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .deleteCanceled:
                state.isProcessing = false
                return .none

            case .deleteTapped:
                state.isProcessing = true
                return .none
            }
        }
    }
}
