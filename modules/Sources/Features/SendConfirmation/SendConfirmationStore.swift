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
import AddressBookClient

@Reducer
public struct SendConfirmation {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case sending
        }
        
        public enum Result: Equatable {
            case failure
            case partial
            case resubmission
            case success
        }

        public var address: String
        @Shared(.inMemory(.addressBookContacts)) public var addressBookContacts: AddressBookContacts = .empty
        public var alias: String?
        @Presents public var alert: AlertState<Action>?
        public var amount: Zatoshi
        public var currencyAmount: RedactableString
        public var destination: Destination?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var feeRequired: Zatoshi
        public var isAddressExpanded = false
        public var isSending = false
        public var isTransparentAddress = false
        public var message: String
        public var partialProposalErrorState: PartialProposalError.State
        public var partialProposalErrorViewBinding = false
        public var proposal: Proposal?
        public var result: Result?

        public var addressToShow: String {
            isTransparentAddress
            ? address
            : isAddressExpanded
            ? address
            : address.zip316
        }
        
        public var successIlustration: Image {
            let rand = Int.random(in: 1...2)
            switch rand {
            case 1: return Asset.Assets.Illustrations.success1.image
            default: return Asset.Assets.Illustrations.success2.image
            }
            
        }

        public var failureIlustration: Image {
            let rand = Int.random(in: 1...3)
            switch rand {
            case 1: return Asset.Assets.Illustrations.failure1.image
            case 2: return Asset.Assets.Illustrations.failure2.image
            default: return Asset.Assets.Illustrations.failure3.image
            }
        }

        public var resubmissionIlustration: Image {
            let rand = Int.random(in: 1...2)
            switch rand {
            case 1: return Asset.Assets.Illustrations.resubmission1.image
            default: return Asset.Assets.Illustrations.resubmission2.image
            }
        }

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
        case closeTapped
        case fetchedABContacts(AddressBookContacts)
        case goBackPressed
        case goBackPressedFromRequestZec
        case onAppear
        case partialProposalError(PartialProposalError.Action)
        case partialProposalErrorDismiss
        case saveAddressTapped(RedactableString)
        case sendDone
        case sendFailed(ZcashError?, Bool)
        case sendPartial([String], [String])
        case sendPressed
        case sendTriggered
        case showHideButtonTapped
        case updateDestination(State.Destination?)
        case updateResult(State.Result?)
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.partialProposalErrorState, action: \.partialProposalError) {
            PartialProposalError()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isTransparentAddress = derivationTool.isTransparentAddress(state.address, zcashSDKEnvironment.network.networkType)
                state.alias = nil
                do {
                    let abContacts = try addressBook.allLocalContacts()
                    return .send(.fetchedABContacts(abContacts))
                } catch {
                    print("__LD fetchABContactsRequested Error: \(error.localizedDescription)")
                    // TODO: FIXME
                    return .none
                }

            case .fetchedABContacts(let abContacts):
                state.addressBookContacts = abContacts
                state.alias = nil
                for contact in state.addressBookContacts.contacts {
                    if contact.id == state.address {
                        state.alias = contact.name
                        break
                    }
                }
                return .none
                
            case .alert(.presented(let action)):
                return .send(action)

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .binding:
                return .none

            case .closeTapped:
                return .none
                
            case .saveAddressTapped:
                return .none

            case .showHideButtonTapped:
                state.isAddressExpanded.toggle()
                return .none

            case .goBackPressedFromRequestZec:
                return .none

            case .goBackPressed:
                return .none
                
            case .sendPressed:
                if state.featureFlags.sendingScreen {
                    state.isSending = true
                    return .concatenate(
                        .send(.updateDestination(.sending)),
                        .send(.sendTriggered)
                    )
                } else {
                    return .send(.sendTriggered)
                }
                
            case .sendTriggered:
                guard let proposal = state.proposal else {
                    return .send(.sendFailed("missing proposal".toZcashError(), true))
                }
                return .run { send in
                    if await !localAuthentication.authenticate() {
                        await send(.sendFailed(nil, true))
                        return
                    }

                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        switch result {
                        case .grpcFailure:
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), true))
                        case .failure:
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), false))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.sendPartial(txIds, statuses))
                        case .success:
                            await send(.sendDone)
                        }
                    } catch {
                        await send(.sendFailed(error.toZcashError(), true))
                    }
                }

            case .sendDone:
                state.isSending = false
                if state.featureFlags.sendingScreen {
                    return .send(.updateResult(.success))
                } else {
                    return .none
                }

            case let .sendFailed(error, isFatal):
                state.isSending = false
                if state.featureFlags.sendingScreen {
                    return .send(.updateResult(isFatal ? .failure : .resubmission))
                } else {
                    return .none
                }
                
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
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .updateResult(let result):
                state.result = result
                return .none
            }
        }
    }
}
