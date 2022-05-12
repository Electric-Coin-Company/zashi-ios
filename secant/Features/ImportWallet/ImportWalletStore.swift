//
//  ImportWalletStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import ComposableArchitecture
import ZcashLightClientKit

typealias ImportWalletReducer = Reducer<ImportWalletState, ImportWalletAction, ImportWalletEnvironment>
typealias ImportWalletStore = Store<ImportWalletState, ImportWalletAction>
typealias ImportWalletViewStore = ViewStore<ImportWalletState, ImportWalletAction>

// MARK: - State

struct ImportWalletState: Equatable {
    @BindableState var alert: AlertState<ImportWalletAction>?
    @BindableState var importedSeedPhrase: String = ""
}

// MARK: - Action

enum ImportWalletAction: Equatable, BindableAction {
    case binding(BindingAction<ImportWalletState>)
    case dismissAlert
    case importRecoveryPhrase
    case importPrivateOrViewingKey
    case initializeSDK
    case successfullyRecovered
}

// MARK: - Environment

struct ImportWalletEnvironment {
    let mnemonicSeedPhraseProvider: WrappedMnemonic
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension ImportWalletEnvironment {
    static let live = ImportWalletEnvironment(
        mnemonicSeedPhraseProvider: .live,
        walletStorage: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let demo = ImportWalletEnvironment(
        mnemonicSeedPhraseProvider: .mock,
        walletStorage: .live(),
        zcashSDKEnvironment: .testnet
    )
}

// MARK: - Reducer

extension ImportWalletReducer {
    static let `default` = ImportWalletReducer { state, action, environment in
        switch action {
        case .binding:
            return .none

        case .dismissAlert:
            state.alert = nil
            return .none
            
        case .importRecoveryPhrase:
            do {
                // validate the seed
                try environment.mnemonicSeedPhraseProvider.isValid(state.importedSeedPhrase)
                
                // store it to the keychain
                let birthday = environment.zcashSDKEnvironment.defaultBirthday
                try environment.walletStorage.importWallet(state.importedSeedPhrase, birthday, .english, false)
                
                // update the backup phrase validation flag
                try environment.walletStorage.markUserPassedPhraseBackupTest()

                // notify user
                // TODO: Proper Error/Success handling, issue 221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.alert = AlertState(
                    title: TextState("Success"),
                    message: TextState("The wallet has been successfully recovered."),
                    dismissButton: .default(
                        TextState("Ok"),
                        action: .send(.successfullyRecovered)
                    )
                )

                return Effect(value: .initializeSDK)
            } catch {
                // TODO: Proper Error/Success handling, issue 221 (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.alert = AlertState(
                    title: TextState("Wrong Seed Phrase"),
                    message: TextState("The seed phrase must be 24 words separated by space."),
                    dismissButton: .default(
                        TextState("Ok"),
                        action: .send(.dismissAlert)
                    )
                )
            }
            
            return .none
            
        case .importPrivateOrViewingKey:
            return .none
            
        case .successfullyRecovered:
            return Effect(value: .dismissAlert)
        
        case .initializeSDK:
            return .none
        }
    }
    .binding()
}

// MARK: - Placeholders

extension ImportWalletState {
    static let placeholder = ImportWalletState(importedSeedPhrase: "")

    static let live = ImportWalletState(importedSeedPhrase: "")
}

extension ImportWalletStore {
    static let demo = Store(
        initialState: .placeholder,
        reducer: .default,
        environment: .demo
    )
}
