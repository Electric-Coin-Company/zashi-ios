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

@Reducer
public struct SecurityWarning {
    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var appBuild = ""
        public var appVersion = ""
        /// This flag holds information whether a user acknowledged the consent or not. `false` by default.
        public var isAcknowledged: Bool = false
        /// This boolean is a TCA view binding, `false` by default = recovery phrase view is not presented, `true` = presented.
        public var recoveryPhraseDisplayViewBinding: Bool = false
        public var recoveryPhraseDisplayState: RecoveryPhraseDisplay.State
        
        public init(
            appBuild: String = "",
            appVersion: String = "",
            recoveryPhraseDisplayViewBinding: Bool = false,
            recoveryPhraseDisplayState: RecoveryPhraseDisplay.State
        ) {
            self.appBuild = appBuild
            self.appVersion = appVersion
            self.recoveryPhraseDisplayViewBinding = recoveryPhraseDisplayViewBinding
            self.recoveryPhraseDisplayState = recoveryPhraseDisplayState
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<SecurityWarning.State>)
        case confirmTapped
        case newWalletCreated
        case onAppear
        case recoveryPhraseDisplay(RecoveryPhraseDisplay.Action)
    }

    @Dependency(\.appVersion) var appVersion
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.recoveryPhraseDisplayState, action: /Action.recoveryPhraseDisplay) {
            RecoveryPhraseDisplay()
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
                
            case .binding:
                return .none

            case .confirmTapped:
                do {
                    // get the random english mnemonic
                    let newRandomPhrase = try mnemonic.randomMnemonic()
                    let birthday = zcashSDKEnvironment.latestCheckpoint
                    
                    // store the wallet to the keychain
                    try walletStorage.importWallet(newRandomPhrase, birthday, .english, false)
                    
                    state.recoveryPhraseDisplayViewBinding = true
                    
                    return Effect.send(.newWalletCreated)
                } catch {
                    state.alert = AlertState.cantCreateNewWallet(error.toZcashError())
                }
                return .none

            case .newWalletCreated:
                return .none
                
            case .recoveryPhraseDisplay(.finishedPressed):
                state.recoveryPhraseDisplayViewBinding = false
                return .none
                
            case .recoveryPhraseDisplay:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SecurityWarning.Action {
    public static func cantCreateNewWallet(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Root.Initialization.Alert.Failed.title)
        } message: {
            TextState(L10n.Root.Initialization.Alert.CantCreateNewWallet.message(error.detailedMessage))
        }
    }
}
