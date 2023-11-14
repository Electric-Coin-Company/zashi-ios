//
//  SecurityWarningStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.10.2023.
//

import Foundation
import ComposableArchitecture
import AppVersion
import RecoveryPhraseDisplay
import MnemonicClient
import WalletStorage
import ZcashSDKEnvironment
import ZcashLightClientKit
import Models
import Generated
import Utils
import SwiftUI

public typealias SecurityWarningStore = Store<SecurityWarningReducer.State, SecurityWarningReducer.Action>
public typealias SecurityWarningViewStore = ViewStore<SecurityWarningReducer.State, SecurityWarningReducer.Action>

public struct SecurityWarningReducer: ReducerProtocol {
    let zcashNetwork: ZcashNetwork

    public struct State: Equatable {
        public enum Destination: Equatable, CaseIterable {
            case createNewWallet
        }

        @PresentationState public var alert: AlertState<Action>?
        public var appBuild = ""
        public var appVersion = ""
        public var destination: Destination?
        @BindingState public var isAcknowledged: Bool = false
        public var recoveryPhraseDisplayState: RecoveryPhraseDisplayReducer.State
        
        public init(
            appBuild: String = "",
            appVersion: String = "",
            destination: Destination? = nil,
            recoveryPhraseDisplayState: RecoveryPhraseDisplayReducer.State
        ) {
            self.appBuild = appBuild
            self.appVersion = appVersion
            self.destination = destination
            self.recoveryPhraseDisplayState = recoveryPhraseDisplayState
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<SecurityWarningReducer.State>)
        case confirmTapped
        case newWalletCreated
        case onAppear
        case recoveryPhraseDisplay(RecoveryPhraseDisplayReducer.Action)
        case updateDestination(SecurityWarningReducer.State.Destination?)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init(zcashNetwork: ZcashNetwork) {
        self.zcashNetwork = zcashNetwork
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Scope(state: \.recoveryPhraseDisplayState, action: /Action.recoveryPhraseDisplay) {
            RecoveryPhraseDisplayReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.appBuild = appVersion.appBuild()
                state.appVersion = appVersion.appVersion()
                return .none

            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .confirmTapped:
                do {
                    // get the random english mnemonic
                    let newRandomPhrase = try mnemonic.randomMnemonic()
                    let birthday = zcashSDKEnvironment.latestCheckpoint(zcashNetwork)
                    
                    // store the wallet to the keychain
                    try walletStorage.importWallet(newRandomPhrase, birthday, .english, true)
                    
                    return .concatenate(
                        Effect.send(.newWalletCreated),
                        Effect.send(.updateDestination(.createNewWallet))
                    )
                } catch {
                    state.alert = AlertState.cantCreateNewWallet(error.toZcashError())
                }
                return .none

            case .newWalletCreated:
                return .none
                
            case .binding(\.$isAcknowledged):
                return .none
                
            case .binding:
                return .none
            
            case .recoveryPhraseDisplay(.finishedPressed):
                state.destination = nil
                return .none
                
            case .recoveryPhraseDisplay:
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none
            }
        }
    }
}

// MARK: - Store

extension SecurityWarningStore {
    public static var demo = SecurityWarningStore(
        initialState: .placeholder,
        reducer: SecurityWarningReducer(zcashNetwork: ZcashNetworkBuilder.network(for: .testnet))
    )
}

// MARK: - ViewStore

extension SecurityWarningViewStore {
    func bindingForDestination(_ destination: SecurityWarningReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }
}

// MARK: Alerts

extension AlertState where Action == SecurityWarningReducer.Action {
    public static func cantCreateNewWallet(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.CantCreateNewWallet.message(error.message, error.code.rawValue))
        }
    }
}

// MARK: - Placeholders

extension SecurityWarningReducer.State {
    public static let placeholder = SecurityWarningReducer.State(
        recoveryPhraseDisplayState: RecoveryPhraseDisplayReducer.State(phrase: .placeholder)
    )
    
    public static let initial = SecurityWarningReducer.State(
        recoveryPhraseDisplayState: RecoveryPhraseDisplayReducer.State(
            phrase: .initial
        )
    )
}
