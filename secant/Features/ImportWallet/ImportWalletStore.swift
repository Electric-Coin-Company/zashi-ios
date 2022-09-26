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
    @BindableState var birthdayHeight: String = ""
    var wordsCount = 0
    var maxWordsCount = 0
    var isValidMnemonic = false
    var isValidNumberOfWords = false
    var birthdayHeightValue: BlockHeight?
    
    var mnemonicStatus: String {
        if isValidMnemonic {
            return "VALID SEED PHRASE"
        } else {
            return "\(wordsCount)/\(maxWordsCount)"
        }
    }
    
    var isValidForm: Bool {
        isValidMnemonic &&
        (birthdayHeight.isEmpty ||
        (!birthdayHeight.isEmpty && birthdayHeightValue != nil))
    }
}

// MARK: - Action

enum ImportWalletAction: Equatable, BindableAction {
    case binding(BindingAction<ImportWalletState>)
    case dismissAlert
    case restoreWallet
    case importPrivateOrViewingKey
    case initializeSDK
    case onAppear
    case successfullyRecovered
}

// MARK: - Environment

struct ImportWalletEnvironment {
    let mnemonic: WrappedMnemonic
    let walletStorage: WrappedWalletStorage
    let zcashSDKEnvironment: ZCashSDKEnvironment
}

extension ImportWalletEnvironment {
    static let live = ImportWalletEnvironment(
        mnemonic: .live,
        walletStorage: .live(),
        zcashSDKEnvironment: .mainnet
    )

    static let demo = ImportWalletEnvironment(
        mnemonic: .mock,
        walletStorage: .live(),
        zcashSDKEnvironment: .testnet
    )
}

// MARK: - Reducer

extension ImportWalletReducer {
    static let `default` = ImportWalletReducer { state, action, environment in
        switch action {
        case .onAppear:
            state.maxWordsCount = environment.zcashSDKEnvironment.mnemonicWordsMaxCount
            return .none
            
        case .binding(\.$importedSeedPhrase):
            state.wordsCount = state.importedSeedPhrase.split(separator: " ").count
            state.isValidNumberOfWords = state.wordsCount == state.maxWordsCount
            // is the mnemonic valid one?
            do {
                try environment.mnemonic.isValid(state.importedSeedPhrase)
            } catch {
                state.isValidMnemonic = false
                return .none
            }
            state.isValidMnemonic = true
            return .none

        case .binding(\.$birthdayHeight):
            if let birthdayHeight = BlockHeight(state.birthdayHeight), birthdayHeight >= environment.zcashSDKEnvironment.defaultBirthday {
                state.birthdayHeightValue = birthdayHeight
            } else {
                state.birthdayHeightValue = nil
            }
            return .none

        case .binding:
            return .none

        case .dismissAlert:
            state.alert = nil
            return .none
            
        case .restoreWallet:
            do {
                // validate the seed
                try environment.mnemonic.isValid(state.importedSeedPhrase)
                
                // store it to the keychain
                var birthday = state.birthdayHeightValue ?? environment.zcashSDKEnvironment.defaultBirthday
                try environment.walletStorage.importWallet(state.importedSeedPhrase, birthday, .english, false)
                
                // update the backup phrase validation flag
                try environment.walletStorage.markUserPassedPhraseBackupTest()

                // notify user
                // TODO [#221]: Proper Error/Success handling (https://github.com/zcash/secant-ios-wallet/issues/221)
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
                // TODO [#221]: Proper Error/Success handling (https://github.com/zcash/secant-ios-wallet/issues/221)
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
    static let placeholder = ImportWalletState()

    static let live = ImportWalletState()
}

extension ImportWalletStore {
    static let demo = Store(
        initialState: .placeholder,
        reducer: .default,
        environment: .demo
    )
}
