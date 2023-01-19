//
//  ImportWalletStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import ComposableArchitecture
import ZcashLightClientKit

typealias ImportWalletStore = Store<ImportWalletReducer.State, ImportWalletReducer.Action>
typealias ImportWalletViewStore = ViewStore<ImportWalletReducer.State, ImportWalletReducer.Action>

struct ImportWalletReducer: ReducerProtocol {
    struct State: Equatable {
        @BindableState var alert: AlertState<ImportWalletReducer.Action>?
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

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<ImportWalletReducer.State>)
        case dismissAlert
        case restoreWallet
        case importPrivateOrViewingKey
        case initializeSDK
        case onAppear
        case successfullyRecovered
    }

    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.maxWordsCount = zcashSDKEnvironment.mnemonicWordsMaxCount
                return .none
                
            case .binding(\.$importedSeedPhrase):
                state.wordsCount = state.importedSeedPhrase.split(separator: " ").count
                state.isValidNumberOfWords = state.wordsCount == state.maxWordsCount
                // is the mnemonic valid one?
                do {
                    try mnemonic.isValid(state.importedSeedPhrase)
                } catch {
                    state.isValidMnemonic = false
                    return .none
                }
                state.isValidMnemonic = true
                return .none
                
            case .binding(\.$birthdayHeight):
                if let birthdayHeight = BlockHeight(state.birthdayHeight), birthdayHeight >= zcashSDKEnvironment.defaultBirthday {
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
                    try mnemonic.isValid(state.importedSeedPhrase)
                    
                    // store it to the keychain
                    let birthday = state.birthdayHeightValue ?? zcashSDKEnvironment.defaultBirthday
                    try walletStorage.importWallet(state.importedSeedPhrase, birthday, .english, false)
                    
                    // update the backup phrase validation flag
                    try walletStorage.markUserPassedPhraseBackupTest()
                    
                    // notify user
                    // TODO: [#221] Proper Error/Success handling (https://github.com/zcash/secant-ios-wallet/issues/221)
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
                    // TODO: [#221] Proper Error/Success handling (https://github.com/zcash/secant-ios-wallet/issues/221)
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
    }
}

// MARK: - Placeholders

extension ImportWalletReducer.State {
    static let placeholder = ImportWalletReducer.State()

    static let live = ImportWalletReducer.State()
}

extension ImportWalletStore {
    static let demo = Store(
        initialState: .placeholder,
        reducer: ImportWalletReducer()
    )
}
