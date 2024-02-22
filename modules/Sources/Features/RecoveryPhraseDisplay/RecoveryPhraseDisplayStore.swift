//
//  RecoveryPhraseDisplayStore.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import Foundation
import ComposableArchitecture
import Models
import Pasteboard
import WalletStorage
import ZcashLightClientKit
import Utils
import Generated
import NumberFormatter

@Reducer
public struct RecoveryPhraseDisplay {
    @ObservableState
    public struct State: Equatable {
        @Presents public var alert: AlertState<Action>?
        public var phrase: RecoveryPhrase?
        public var showBackButton = false
        public var showCopyToBufferAlert = false
        public var birthday: Birthday?
        public var birthdayValue: String?
        
        public init(
            phrase: RecoveryPhrase? = nil,
            showBackButton: Bool = false,
            showCopyToBufferAlert: Bool = false,
            birthday: Birthday? = nil,
            birthdayValue: String? = nil
        ) {
            self.phrase = phrase
            self.showBackButton = showBackButton
            self.showCopyToBufferAlert = showCopyToBufferAlert
            self.birthday = birthday
            self.birthdayValue = birthdayValue
        }
    }
    
    public enum Action: Equatable {
        case alert(PresentationAction<Action>)
        case copyToBufferPressed
        case finishedPressed
        case onAppear
    }
    
    @Dependency(\.pasteboard) var pasteboard
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.numberFormatter) var numberFormatter

    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                do {
                    let storedWallet = try walletStorage.exportWallet()
                    state.birthday = storedWallet.birthday
                    
                    if let value = state.birthday?.value() {
                        let latestBlock = numberFormatter.string(NSDecimalNumber(value: value))
                        state.birthdayValue = "\(String(describing: latestBlock ?? ""))"
                    }
                    
                    let seedWords = storedWallet.seedPhrase.value().split(separator: " ").map { RedactableString(String($0)) }
                    state.phrase = RecoveryPhrase(words: seedWords)
                } catch {
                    state.alert = AlertState.storedWalletFailure(error.toZcashError())
                }
                
                return .none
                
            case .alert(.presented(let action)):
                return Effect.send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .copyToBufferPressed:
                guard let phrase = state.phrase?.toString() else { return .none }
                pasteboard.setString(phrase)
                state.showCopyToBufferAlert = true
                return .none
                
            case .finishedPressed:
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == RecoveryPhraseDisplay.Action {
    public static func storedWalletFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.RecoveryPhraseDisplay.Alert.Failed.title)
        } message: {
            TextState(L10n.RecoveryPhraseDisplay.Alert.Failed.message(error.message, error.code))
        }
    }
}
