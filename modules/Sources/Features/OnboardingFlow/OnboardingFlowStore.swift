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

@Reducer
public struct OnboardingFlow {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case createNewWallet
            case importExistingWallet
        }

        public var destination: Destination?
        public var walletConfig: WalletConfig
        public var importWalletState: ImportWallet.State
        public var securityWarningState: SecurityWarning.State

        public init(
            destination: Destination? = nil,
            walletConfig: WalletConfig,
            importWalletState: ImportWallet.State,
            securityWarningState: SecurityWarning.State
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
        case importWallet(ImportWallet.Action)
        case onAppear
        case securityWarning(SecurityWarning.Action)
        case updateDestination(OnboardingFlow.State.Destination?)
    }
    
    public init() { }
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.importWalletState, action: \.importWallet) {
            ImportWallet()
        }

        Scope(state: \.securityWarningState, action: \.securityWarning) {
            SecurityWarning()
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
