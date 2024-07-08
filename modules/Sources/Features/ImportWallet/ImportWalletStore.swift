//
//  ImportWalletStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/25/2022.
//

import ComposableArchitecture
import ZcashLightClientKit
import SwiftUI
import Utils
import Generated
import WalletStorage
import MnemonicClient
import ZcashSDKEnvironment
import RestoreInfo

@Reducer
public struct ImportWallet {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case birthday
            case restoreInfo
        }

        @Presents public var alert: AlertState<Action>?
        public var birthdayHeight = RedactableString.empty
        public var birthdayHeightValue: RedactableBlockHeight?
        public var destination: Destination?
        public var importedSeedPhrase = RedactableString.empty
        public var isValidMnemonic = false
        public var isValidNumberOfWords = false
        public var maxWordsCount = 0
        public var restoreInfoState: RestoreInfo.State
        public var wordsCount = 0
        
        public var mnemonicStatus: String {
            if isValidMnemonic {
                return L10n.ImportWallet.Seed.valid
            } else {
                return "\(wordsCount)/\(maxWordsCount)"
            }
        }
        
        public var isValidForm: Bool {
            isValidMnemonic &&
            (birthdayHeight.data.isEmpty ||
            (!birthdayHeight.data.isEmpty && birthdayHeightValue != nil))
        }
        
        public init(
            birthdayHeight: RedactableString = .empty,
            birthdayHeightValue: RedactableBlockHeight? = nil,
            destination: Destination? = nil,
            importedSeedPhrase: RedactableString = .empty,
            isValidMnemonic: Bool = false,
            isValidNumberOfWords: Bool = false,
            maxWordsCount: Int = 0,
            restoreInfoState: RestoreInfo.State,
            wordsCount: Int = 0
        ) {
            self.birthdayHeight = birthdayHeight
            self.birthdayHeightValue = birthdayHeightValue
            self.destination = destination
            self.importedSeedPhrase = importedSeedPhrase
            self.isValidMnemonic = isValidMnemonic
            self.isValidNumberOfWords = isValidNumberOfWords
            self.maxWordsCount = maxWordsCount
            self.restoreInfoState = restoreInfoState
            self.wordsCount = wordsCount
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<ImportWallet.State>)
        case birthdayInputChanged(RedactableString)
        case importPrivateOrViewingKey
        case initializeSDK
        case nextPressed
        case onAppear
        case restoreInfo(RestoreInfo.Action)
        case restoreInfoRequested(Bool)
        case restoreWallet
        case seedPhraseInputChanged(RedactableString)
        case successfullyRecovered
        case updateDestination(ImportWallet.State.Destination?)
    }

    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.restoreInfoState, action: \.restoreInfo) {
            RestoreInfo()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.maxWordsCount = zcashSDKEnvironment.mnemonicWordsMaxCount
                return .none
                
            case .binding:
                return .none
                
            case .seedPhraseInputChanged(let redactedSeedPhrase):
                state.importedSeedPhrase = redactedSeedPhrase
                state.wordsCount = state.importedSeedPhrase.data.split(separator: " ").count
                state.isValidNumberOfWords = state.wordsCount == state.maxWordsCount
                // is the mnemonic valid one?
                do {
                    try mnemonic.isValid(state.importedSeedPhrase.data)
                } catch {
                    state.isValidMnemonic = false
                    return .none
                }
                state.isValidMnemonic = true
                return .none
                
            case .birthdayInputChanged(let redactedBirthday):
                let saplingActivation = zcashSDKEnvironment.network.constants.saplingActivationHeight

                state.birthdayHeight = redactedBirthday

                if let birthdayHeight = BlockHeight(state.birthdayHeight.data), birthdayHeight >= saplingActivation {
                    state.birthdayHeightValue = birthdayHeight.redacted
                } else {
                    state.birthdayHeightValue = nil
                }
                return .none
                
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none
                
            case .nextPressed:
                return .none
                
            case .restoreInfo:
                return .none
                
            case .restoreInfoRequested(let newValue):
                return .send(.updateDestination(.restoreInfo))
                
            case .restoreWallet:
                do {
                    // validate the seed
                    try mnemonic.isValid(state.importedSeedPhrase.data)
                    
                    // store it to the keychain, if the user did not input a height,
                    // fall back to sapling activation
                    let birthday = state.birthdayHeightValue ?? zcashSDKEnvironment.network.constants.saplingActivationHeight.redacted
                    
                    try walletStorage.importWallet(state.importedSeedPhrase.data, birthday.data, .english, false)
                    
                    // update the backup phrase validation flag
                    try walletStorage.markUserPassedPhraseBackupTest(true)

                    state.birthdayHeight = .empty
                    state.importedSeedPhrase = .empty
                    state.destination = nil
                    
                    // notify user
                    return .concatenate(
                        Effect.send(.successfullyRecovered),
                        Effect.send(.initializeSDK)
                    )
                } catch {
                    state.alert = AlertState.failed(error.toZcashError())
                }
                return .none

            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .importPrivateOrViewingKey:
                return .none
                
            case .successfullyRecovered:
                return .send(.updateDestination(nil))
                
            case .initializeSDK:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == ImportWallet.Action {
    public static func failed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.ImportWallet.Alert.Failed.title)
        } actions: {
            ButtonState(action: .alert(.dismiss)) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.ImportWallet.Alert.Failed.message(error.detailedMessage))
        }
    }
}
