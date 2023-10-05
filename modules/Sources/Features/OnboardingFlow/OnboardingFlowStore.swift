//
//  Onboarding.swift
//  OnboardingTCA
//
//  Created by Adam Stener on 10/10/21.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Generated
import Models
import ImportWallet
import SecurityWarning
import ZcashLightClientKit

public typealias OnboardingFlowStore = Store<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>
public typealias OnboardingFlowViewStore = ViewStore<OnboardingFlowReducer.State, OnboardingFlowReducer.Action>

public struct OnboardingFlowReducer: ReducerProtocol {
    let saplingActivationHeight: BlockHeight
    let zcashNetwork: ZcashNetwork

    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case createNewWallet
            case importExistingWallet
        }

        public var destination: Destination?
        public var walletConfig: WalletConfig
        public var importWalletState: ImportWalletReducer.State
        public var securityWarningState: SecurityWarningReducer.State

        public init(
            destination: Destination? = nil,
            walletConfig: WalletConfig,
            importWalletState: ImportWalletReducer.State,
            securityWarningState: SecurityWarningReducer.State
        ) {
            self.destination = destination
            self.walletConfig = walletConfig
            self.importWalletState = importWalletState
            self.securityWarningState = securityWarningState
        }
    }

    public enum Action: Equatable {
        case createNewWallet
        case importExistingWallet
        case importWallet(ImportWalletReducer.Action)
        case onAppear
        case securityWarning(SecurityWarningReducer.Action)
        case updateDestination(OnboardingFlowReducer.State.Destination?)
    }
    
    public init(saplingActivationHeight: BlockHeight, zcashNetwork: ZcashNetwork) {
        self.saplingActivationHeight = saplingActivationHeight
        self.zcashNetwork = zcashNetwork
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.importWalletState, action: /Action.importWallet) {
            ImportWalletReducer(saplingActivationHeight: saplingActivationHeight)
        }

        Scope(state: \.securityWarningState, action: /Action.securityWarning) {
            SecurityWarningReducer(zcashNetwork: zcashNetwork)
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .createNewWallet:
                state.destination = .createNewWallet
                return .none

            case .importExistingWallet:
                state.destination = .importExistingWallet
                return .none
                
            case .importWallet:
                return .none
                
            case .securityWarning:
                return .none
            }
        }
    }
}

// MARK: - ViewStore

extension OnboardingFlowViewStore {
    func bindingForDestination(_ destination: OnboardingFlowReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}
