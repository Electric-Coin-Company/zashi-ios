//
//  SendConfirmationStore.swift
//  
//
//  Created by Lukáš Korba on 13.05.2024.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import AudioServices
import Utils
import Scan
import PartialProposalError
import MnemonicClient
import SDKSynchronizer
import WalletStorage
import ZcashSDKEnvironment
import UIComponents
import Models
import Generated
import BalanceFormatter
import WalletBalances
import LocalAuthenticationHandler

@Reducer
public struct SendConfirmation {
    @ObservableState
    public struct State: Equatable {
        public var address: String
        @Presents public var alert: AlertState<Action>?
        public var amount: Zatoshi
        public var currencyAmount: RedactableString
        public var feeRequired: Zatoshi
        public var isSending: Bool = false
        public var message: String
        public var partialProposalErrorState: PartialProposalError.State
        public var partialProposalErrorViewBinding: Bool = false
        public var proposal: Proposal?

        public init(
            address: String,
            amount: Zatoshi,
            currencyAmount: RedactableString = .empty,
            feeRequired: Zatoshi,
            isSending: Bool = false,
            message: String,
            partialProposalErrorState: PartialProposalError.State,
            partialProposalErrorViewBinding: Bool = false,
            proposal: Proposal?
        ) {
            self.address = address
            self.amount = amount
            self.currencyAmount = currencyAmount
            self.feeRequired = feeRequired
            self.isSending = isSending
            self.message = message
            self.partialProposalErrorState = partialProposalErrorState
            self.partialProposalErrorViewBinding = partialProposalErrorViewBinding
            self.proposal = proposal
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case alert(PresentationAction<Action>)
        case binding(BindingAction<SendConfirmation.State>)
        case goBackPressed
        case partialProposalError(PartialProposalError.Action)
        case partialProposalErrorDismiss
        case sendDone
        case sendFailed(ZcashError?)
        case sendPartial([String], [String])
        case sendPressed
    }

    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.partialProposalErrorState, action: /Action.partialProposalError) {
            PartialProposalError()
        }

        Reduce { state, action in
            switch action {
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .binding:
                return .none
                
            case .goBackPressed:
                return .none
                
            case .sendPressed:
                state.isSending = true

                guard let proposal = state.proposal else {
                    return .send(.sendFailed("missing proposal".toZcashError()))
                }

                return .run { send in
                    if await !localAuthentication.authenticate() {
                        await send(.sendFailed(nil))
                        return
                    }

                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        switch result {
                        case .failure:
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.sendPartial(txIds, statuses))
                        case .success:
                            await send(.sendDone)
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError()))
                    }
                }

            case .sendDone:
                state.isSending = false
                return .none
                
            case .sendFailed(let error):
                state.isSending = false
                if let error {
                    state.alert = AlertState.sendFailure(error)
                }
                return .none
                
            case let .sendPartial(txIds, statuses):
                state.isSending = false
                state.partialProposalErrorViewBinding = true
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .none
                
            case .partialProposalError:
                return .none
                
            case .partialProposalErrorDismiss:
                state.partialProposalErrorViewBinding = false
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == SendConfirmation.Action {
    public static func sendFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Send.Alert.Failure.title)
        } message: {
            TextState(L10n.Send.Alert.Failure.message(error.detailedMessage))
        }
    }
}
