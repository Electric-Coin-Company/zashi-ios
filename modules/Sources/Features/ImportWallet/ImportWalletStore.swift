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

public typealias ImportWalletStore = Store<ImportWalletReducer.State, ImportWalletReducer.Action>
public typealias ImportWalletViewStore = ViewStore<ImportWalletReducer.State, ImportWalletReducer.Action>

public struct ImportWalletReducer: ReducerProtocol {
    let saplingActivationHeight: BlockHeight
    
    public struct State: Equatable {
        public enum Destination: Equatable {
            case birthday
        }

        @PresentationState public var alert: AlertState<Action>?
        public var birthdayHeight = "".redacted
        public var birthdayHeightValue: RedactableBlockHeight?
        public var destination: Destination?
        public var importedSeedPhrase = "".redacted
        public var isValidMnemonic = false
        public var isValidNumberOfWords = false
        public var maxWordsCount = 0
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
            birthdayHeight: RedactableString = "".redacted,
            birthdayHeightValue: RedactableBlockHeight? = nil,
            destination: Destination? = nil,
            importedSeedPhrase: RedactableString = "".redacted,
            isValidMnemonic: Bool = false,
            isValidNumberOfWords: Bool = false,
            maxWordsCount: Int = 0,
            wordsCount: Int = 0
        ) {
            self.alert = alert
            self.birthdayHeight = birthdayHeight
            self.birthdayHeightValue = birthdayHeightValue
            self.destination = destination
            self.importedSeedPhrase = importedSeedPhrase
            self.isValidMnemonic = isValidMnemonic
            self.isValidNumberOfWords = isValidNumberOfWords
            self.maxWordsCount = maxWordsCount
            self.wordsCount = wordsCount
        }
    }
    
    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case birthdayInputChanged(RedactableString)
        case restoreWallet
        case importPrivateOrViewingKey
        case initializeSDK
        case onAppear
        case seedPhraseInputChanged(RedactableString)
        case successfullyRecovered
        case updateDestination(ImportWalletReducer.State.Destination?)
    }

    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init(saplingActivationHeight: BlockHeight) {
        self.saplingActivationHeight = saplingActivationHeight
    }
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.maxWordsCount = zcashSDKEnvironment.mnemonicWordsMaxCount
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
                let saplingActivation = saplingActivationHeight

                state.birthdayHeight = redactedBirthday

                if let birthdayHeight = BlockHeight(state.birthdayHeight.data), birthdayHeight >= saplingActivation {
                    state.birthdayHeightValue = birthdayHeight.redacted
                } else {
                    state.birthdayHeightValue = nil
                }
                return .none
                
            case .alert(.presented(let action)):
                return EffectTask(value: action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert:
                return .none
                
            case .restoreWallet:
                do {
                    // validate the seed
                    try mnemonic.isValid(state.importedSeedPhrase.data)
                    
                    // store it to the keychain, if the user did not input a height,
                    // fall back to sapling activation
                    let birthday = state.birthdayHeightValue ?? saplingActivationHeight.redacted
                    
                    try walletStorage.importWallet(state.importedSeedPhrase.data, birthday.data, .english, false)
                    
                    // update the backup phrase validation flag
                    try walletStorage.markUserPassedPhraseBackupTest(true)
                    
                    state.alert = AlertState.succeed()
                    
                    // notify user
                    return EffectTask(value: .initializeSDK)
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
                return .none
                
            case .initializeSDK:
                return .none
            }
        }
    }
}

// MARK: - ViewStore

extension ImportWalletViewStore {
    func bindingForDestination(_ destination: ImportWalletReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in
                return .updateDestination(isActive ? destination : nil)
            }
        )
    }

    func bindingForRedactableSeedPhrase(_ importedSeedPhrase: RedactableString) -> Binding<String> {
        self.binding(
            get: { _ in importedSeedPhrase.data },
            send: { .seedPhraseInputChanged($0.redacted) }
        )
    }
    
    func bindingForRedactableBirthday(_ birthdayHeight: RedactableString) -> Binding<String> {
        self.binding(
            get: { _ in birthdayHeight.data },
            send: { .birthdayInputChanged($0.redacted) }
        )
    }
}

// MARK: Alerts

extension AlertState where Action == ImportWalletReducer.Action {
    public static func succeed() -> AlertState {
        AlertState {
            TextState(L10n.General.success)
        } actions: {
            ButtonState(action: .successfullyRecovered) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.ImportWallet.Alert.Success.message)
        }
    }
    
    public static func failed(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.ImportWallet.Alert.Failed.title)
        } actions: {
            ButtonState(action: .alert(.dismiss)) {
                TextState(L10n.General.ok)
            }
        } message: {
            TextState(L10n.ImportWallet.Alert.Failed.message(error.message, error.code.rawValue))
        }
    }
}

// MARK: - Placeholders

extension ImportWalletReducer.State {
    public static let placeholder = ImportWalletReducer.State()

    public static let live = ImportWalletReducer.State()
}

extension ImportWalletStore {
    public static let demo = Store(
        initialState: .placeholder,
        reducer: ImportWalletReducer(saplingActivationHeight: 0)
    )
}
