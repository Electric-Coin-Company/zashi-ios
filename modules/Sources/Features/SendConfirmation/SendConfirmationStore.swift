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
import KeystoneHandler

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

        public enum StackDestination: Int, Equatable {
            case signWithKeystone = 0
            case scan
            case sending
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
        public var isKeystoneCodeFound = false
        public var isSending = false
        public var isShielding = false
        public var isTransparentAddress = false
        public var message: String
        public var messageToBeShared: String?
        public var partialProposalErrorState: PartialProposalError.State
        public var partialProposalErrorViewBinding = false
        public var pczt: Pczt?
        public var pcztWithProofs: Pczt?
        public var pcztWithSigs: Pczt?
        public var proposal: Proposal?
        public var randomSuccessIconIndex = 0
        public var randomFailureIconIndex = 0
        public var randomResubmissionIconIndex = 0
        public var result: Result?
        public var scanState: Scan.State = .initial
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil
        public var sendingScreenOnAppearTimestamp: TimeInterval = 0
        public var stackDestination: StackDestination?
        public var stackDestinationBindingsAlive = 0
        public var supportData: SupportData?
        public var txIdToExpand: String?
        @Shared(.inMemory(.walletAccounts)) public var walletAccounts: [WalletAccount] = []
        @Shared(.inMemory(.zashiWalletAccount)) public var zashiWalletAccount: WalletAccount? = nil

        public var pcztToShare: Pczt?

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
        case confirmWithKeystoneTapped
        case fetchedABContacts(AddressBookContacts)
        case getSignatureTapped
        case goBackPressed
        case goBackPressedFromRequestZec
        case onAppear
        case partialProposalError(PartialProposalError.Action)
        case partialProposalErrorDismiss
        case rejectTapped
        case reportTapped
        case saveAddressTapped(RedactableString)
        case scan(Scan.Action)
        case sendDone
        case sendFailed(ZcashError?, Bool)
        case sendingScreenOnAppear
        case sendPartial([String], [String])
        case sendPressed
        case sendSupportMailFinished
        case sendTriggered
        case shareFinished
        case showHideButtonTapped
        case updateDestination(State.Destination?)
        case updateFailedData(Int, String)
        case updateResult(State.Result?)
        case updateStackDestination(SendConfirmation.State.StackDestination?)
        case updateTxIdToExpand(String?)
        case viewTransactionTapped
        
        // PCZT
        case addProofsToPczt
        case createTransactionFromPCZT
        case pcztResolved(Pczt)
        case pcztWithProofsResolved(Pczt)
        case resetPCZTs
        case resolvePCZT
        case sharePCZT
    }

    @Dependency(\.addressBook) var addressBook
    @Dependency(\.audioServices) var audioServices
    @Dependency(\.localAuthentication) var localAuthentication
    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.keystoneHandler) var keystoneHandler
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

        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.scanState.checkers = [.keystoneScanChecker, .keystonePCZTScanChecker]
                state.scanState.instructions = L10n.Keystone.scanInfoTransaction
                state.scanState.forceLibraryToHide = true
                state.randomSuccessIconIndex = Int.random(in: 1...2)
                state.randomFailureIconIndex = Int.random(in: 1...3)
                state.randomResubmissionIconIndex = Int.random(in: 1...2)
                state.isTransparentAddress = derivationTool.isTransparentAddress(state.address, zcashSDKEnvironment.network.networkType)
                state.canSendMail = MFMailComposeViewController.canSendMail()
                state.alias = nil
                if let account = state.zashiWalletAccount {
                    do {
                        let result = try addressBook.allLocalContacts(account.account)
                        let abContacts = result.contacts
                        if result.remoteStoreResult == .failure {
                            // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        }
                        return .send(.fetchedABContacts(abContacts))
                    } catch {
                        // TODO: [#1408] error handling https://github.com/Electric-Coin-Company/zashi-ios/issues/1408
                        return .none
                    }
                }
                return .none

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
                guard let zip32AccountIndex = state.selectedWalletAccount?.zip32AccountIndex else {
                    return .none
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
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, network)

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
                    let diffTime = Date().timeIntervalSince1970 - state.sendingScreenOnAppearTimestamp
                    let waitTimeToPresentScreen = diffTime > 2.0 ? 0.01 : 2.0 - diffTime
                    return .run { send in
                        try? await mainQueue.sleep(for: .seconds(waitTimeToPresentScreen))
                        await send(.updateResult(.success))
                    }
                } else {
                    return .none
                }

            case let .sendFailed(error, isFatal):
                state.isSending = false
                if state.featureFlags.sendingScreen {
                    let diffTime = Date().timeIntervalSince1970 - state.sendingScreenOnAppearTimestamp
                    let waitTimeToPresentScreen = diffTime > 2.0 ? 0.01 : 2.0 - diffTime
                    return .run { send in
                        try? await mainQueue.sleep(for: .seconds(waitTimeToPresentScreen))
                        await send(.updateResult(isFatal ? .failure : .resubmission))
                    }
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
                
            case .updateStackDestination(let destination):
                if let destination {
                    state.stackDestinationBindingsAlive = destination.rawValue
                }
                state.stackDestination = destination
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
                state.pcztToShare = nil
                return .none
            
            case .sendingScreenOnAppear:
                state.sendingScreenOnAppearTimestamp = Date().timeIntervalSince1970
                return .none
                
                // MARK: - Keystone
                
            case .getSignatureTapped:
                state.isKeystoneCodeFound = false
                keystoneHandler.resetQRDecoder()
                return .send(.updateStackDestination(.scan))
                
            case .rejectTapped:
                return .none
                
            case .confirmWithKeystoneTapped:
                return .concatenate(
                    .send(.resolvePCZT),
                    .send(.updateStackDestination(.signWithKeystone))
                    )
                
            case .scan(.cancelPressed):
                return .send(.updateStackDestination(.signWithKeystone))

            case .scan(.foundPCZT(let pcztWithSigs)):
                if !state.isKeystoneCodeFound {
                    state.isKeystoneCodeFound = true
                    state.pcztWithSigs = pcztWithSigs
                    return .run { send in
                        await send(.updateStackDestination(.sending))
                        await send(.createTransactionFromPCZT)
                    }
                }
                return .none
                
            case .scan:
                return .none
                
            case .resolvePCZT:
                guard let proposal = state.proposal, let account = state.selectedWalletAccount else {
                    return .none
                }
                return .run { send in
                    do {
                        let pczt = try await sdkSynchronizer.createPCZTFromProposal(account.id, proposal)
                        await send(.pcztResolved(pczt))
                    } catch {
                        print(error)
                    }
                }
                
            case .pcztResolved(let pczt):
                state.pczt = pczt
                return .send(.addProofsToPczt)
                
            case .addProofsToPczt:
                guard let pczt = state.pczt else {
                    return .none
                }
                return .run { send in
                    do {
                        let pcztWithProofs = try await sdkSynchronizer.addProofsToPCZT(Pczt(pczt))
                        await send(.pcztWithProofsResolved(pcztWithProofs))
                    } catch {
                        print(error)
                    }
                }
                
            case .pcztWithProofsResolved(let pcztWithProofs):
                state.pcztWithProofs = pcztWithProofs
                return .send(.createTransactionFromPCZT)
                
            case .sharePCZT:
                state.pcztToShare = state.pczt
                return .none
                
            case .createTransactionFromPCZT:
                guard let pcztWithProofs = state.pcztWithProofs, let pcztWithSigs = state.pcztWithSigs else {
                    return .none
                }
                return .run { send in
                    do {
                        let result = try await sdkSynchronizer.createTransactionFromPCZT(pcztWithProofs, pcztWithSigs)
                        
                        await send(.resetPCZTs)

                        switch result {
                        case .grpcFailure(let txIds):
                            await send(.updateFailedData(-999, "grpcFailure"))
                            await send(.updateTxIdToExpand(txIds.last))
                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError(), false))
                        case let .failure(txIds, code, description):
                            if description.isEmpty {
                                await send(.updateFailedData(-997, "result.failure \(txIds)"))
                            } else {
                                await send(.updateFailedData(code, description))
                            }
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
                        await send(.resetPCZTs)
                        await send(.updateFailedData(-998, error.toZcashError().detailedMessage))
                        await send(.sendFailed(error.toZcashError(), true))
                    }
                }
                
            case .resetPCZTs:
                state.pczt = nil
                state.pcztWithProofs = nil
                state.pcztWithSigs = nil
                state.pcztToShare = nil
                state.proposal = nil
                
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

extension Pczt {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
