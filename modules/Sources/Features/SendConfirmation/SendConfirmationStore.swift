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
import MessageUI
import SupportDataGenerator

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
        public var canSendMail = false
        public var currencyAmount: RedactableString
        public var destination: Destination?
        public var failedCode: Int?
        public var failedDescription: String?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var feeRequired: Zatoshi
        public var isAddressExpanded = false
        public var isSending = false
        public var isTransparentAddress = false
        public var message: String
        public var messageToBeShared: String?
        public var partialProposalErrorState: PartialProposalError.State
        public var partialProposalErrorViewBinding = false
        public var proposal: Proposal?
        public var randomSuccessIconIndex = 0
        public var randomFailureIconIndex = 0
        public var randomResubmissionIconIndex = 0
        public var result: Result?
        public var supportData: SupportData?
        public var txIdToExpand: String?

        public var addressToShow: String {
            isTransparentAddress
            ? address
            : isAddressExpanded
            ? address
            : address.zip316
        }
        
        public var successIlustration: Image {
            switch randomSuccessIconIndex {
            case 1: return Asset.Assets.Illustrations.success1.image
            default: return Asset.Assets.Illustrations.success2.image
            }
            
        }

        public var failureIlustration: Image {
            switch randomFailureIconIndex {
            case 1: return Asset.Assets.Illustrations.failure1.image
            case 2: return Asset.Assets.Illustrations.failure2.image
            default: return Asset.Assets.Illustrations.failure3.image
            }
        }

        public var resubmissionIlustration: Image {
            switch randomResubmissionIconIndex {
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
        case backFromFailurePressed
        case binding(BindingAction<SendConfirmation.State>)
        case closeTapped
        case fetchedABContacts(AddressBookContacts)
        case goBackPressed
        case goBackPressedFromRequestZec
        case onAppear
        case partialProposalError(PartialProposalError.Action)
        case partialProposalErrorDismiss
        case reportTapped
        case saveAddressTapped(RedactableString)
        case sendDone
        case sendFailed(ZcashError?, Bool)
        case sendPartial([String], [String])
        case sendPressed
        case sendSupportMailFinished
        case sendTriggered
        case shareFinished
        case showHideButtonTapped
        case updateDestination(State.Destination?)
        case updateFailedData(Int, String)
        case updateResult(State.Result?)
        case updateTxIdToExpand(String?)
        case viewTransactionTapped
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mainQueue) var mainQueue
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
                state.randomSuccessIconIndex = Int.random(in: 1...2)
                state.randomFailureIconIndex = Int.random(in: 1...3)
                state.randomResubmissionIconIndex = Int.random(in: 1...2)
                state.isTransparentAddress = derivationTool.isTransparentAddress(state.address, zcashSDKEnvironment.network.networkType)
                state.canSendMail = MFMailComposeViewController.canSendMail()
                state.alias = nil
                do {
                    let abContacts = try addressBook.allLocalContacts()
                    return .send(.fetchedABContacts(abContacts))
                } catch {
                    // TODO: [#1408] erro handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
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

            case .saveAddressTapped:
                return .none

            case .showHideButtonTapped:
                state.isAddressExpanded.toggle()
                return .none

            case .goBackPressedFromRequestZec:
                return .none

            case .goBackPressed:
                return .none

            case .closeTapped, .viewTransactionTapped, .backFromFailurePressed:
                return .concatenate(
                    .send(.updateDestination(nil)),
                    .send(.updateResult(nil))
                )

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
                        case .grpcFailure(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), false))
                        case let .failure(txIds, code, description):
                            await send(.updateFailedData(code, description))
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), true))
                        case let .partial(txIds: txIds, statuses: statuses):
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendPartial(txIds, statuses))
                        case .success(let txIds):
                            await send(.updateTxIdToExpand(txIds.last))
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
                    if let error {
                        state.alert = AlertState.sendFailure(error)
                    }
                    return .none
                }
                
            case let .sendPartial(txIds, statuses):
                state.isSending = false
                state.partialProposalErrorViewBinding = true
                state.partialProposalErrorState.txIds = txIds
                state.partialProposalErrorState.statuses = statuses
                return .none

            case .updateTxIdToExpand(let txId):
                state.txIdToExpand = txId
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
                if let result {
                    if result == .success {
                        audioServices.systemSoundVibrate()
                        return .none
                    } else {
                        return .run { _ in
                            audioServices.systemSoundVibrate()
                            try? await mainQueue.sleep(for: .seconds(1.0))
                            audioServices.systemSoundVibrate()
                        }
                    }
                } else {
                    return .none
                }
                
            case let .updateFailedData(code, desc):
                state.failedCode = code
                state.failedDescription = desc
                return .none
                
            case .reportTapped:
                var supportData = SupportDataGenerator.generate()
                if let code = state.failedCode, let desc = state.failedDescription {
                    supportData.message =
                    """
                    \(code)
                    
                    \(desc)

                    \(supportData.message)
                    """
                }
                if state.canSendMail {
                    state.supportData = supportData
                } else {
                    state.messageToBeShared = supportData.message
                }
                return .none
                
            case .sendSupportMailFinished:
                state.supportData = nil
                return .none
                
            case .shareFinished:
                state.messageToBeShared = nil
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
