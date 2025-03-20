//
//  SendCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-18.
//

import ComposableArchitecture
import ZcashLightClientKit

import Generated
import AudioServices

import AddressBook
import PartialProposalError
import Scan
import SendConfirmation
import SendForm
import TransactionDetails

extension SendCoordFlow {
    public func coordinatorReduce() -> Reduce<SendCoordFlow.State, SendCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Address Book
                
            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                state.path.removeAll()
                audioServices.systemSoundVibrate()
                return .send(.sendForm(.addressUpdated(address.redacted)))

            case .path(.element(id: _, action: .addressBook(.walletAccountTapped(let contact)))):
                if let address = contact.uAddress?.stringEncoded {
                    state.path.removeAll()
                    audioServices.systemSoundVibrate()
                    return .send(.sendForm(.addressUpdated(address.redacted)))
                }
                return .none

            case .path(.element(id: _, action: .addressBook(.addManualButtonTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isAddressFocused = true
                state.path.append(.addressBookContact(addressBookState))
                return .none

            case .path(.element(id: _, action: .addressBook(.scanButtonTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.zcashAddressScanChecker]
                state.path.append(.scan(scanState))
                return .none

                // MARK: - Address Book Contact

            case .path(.element(id: _, action: .addressBookContact(.dismissAddContactRequired))):
                let _ = state.path.popLast()
                for element in state.path {
                    if element.is(\.scan) {
                        let _ = state.path.popLast()
                        return .none
                    }
                }
                return .none
                
                // MARK: - Request ZEC Confirmation
                
            case .path(.element(id: _, action: .requestZecConfirmation(.goBackTappedFromRequestZec))):
                state.path.removeAll()
                return .none

            case .path(.element(id: _, action: .requestZecConfirmation(.sendTapped))):
                for element in state.path {
                    if case .requestZecConfirmation(let sendConfirmationState) = element {
                        state.path.append(.sending(sendConfirmationState))
                        break
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .requestZecConfirmation(.sendFailed))):
                state.path.removeAll()
                return .none
                
                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundAddress(let address)))):
                // Handling of scan inside address book
                for element in state.path {
                    if element.is(\.addressBook) {
                        var addressBookState = AddressBook.State.initial
                        addressBookState.address = address.data
                        addressBookState.isValidZcashAddress = true
                        addressBookState.isNameFocused = true
                        state.path.append(.addressBookContact(addressBookState))
                        audioServices.systemSoundVibrate()
                        return .none
                    }
                }
                // handling of scan for the send form
                let _ = state.path.popLast()
                audioServices.systemSoundVibrate()
                return .send(.sendForm(.addressUpdated(address)))

            case .path(.element(id: _, action: .scan(.foundRequestZec(let requestPayment)))):
                return .send(.sendForm(.requestZec(requestPayment)))

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none

                // MARK: - Send
                
            case .sendForm(.addressBookTapped):
                var addressBookState = AddressBook.State.initial
                addressBookState.isInSelectMode = true
                state.path.append(.addressBook(addressBookState))
                return .none
                
            case .sendForm(.scanTapped):
                var scanState = Scan.State.initial
                scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                state.path.append(.scan(scanState))
                return .none
                
            case .sendForm(.confirmationRequired(let confirmationType)):
                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.amount = state.sendFormState.amount
                sendConfirmationState.address = state.sendFormState.address.data
                sendConfirmationState.proposal = state.sendFormState.proposal
                sendConfirmationState.feeRequired = state.sendFormState.feeRequired
                sendConfirmationState.message = state.sendFormState.message
                let currencyAmount = state.sendFormState.currencyConversion?.convert(state.sendFormState.amount).redacted ?? .empty
                sendConfirmationState.currencyAmount = currencyAmount
                
                if confirmationType == .send {
                    state.path.append(.sendConfirmation(sendConfirmationState))
                } else if confirmationType == .requestPayment {
                    state.path.append(.requestZecConfirmation(sendConfirmationState))
                }
                return .none
                
            case let .sendForm(.sendFailed(_, confirmationType)):
                if confirmationType == .requestPayment {
                    state.path.removeAll()
                }
                return .none
                
                // MARK: - Send Confirmation

            case .path(.element(id: _, action: .sendConfirmation(.cancelTapped))):
                let _ = state.path.popLast()
                return .none

            case .path(.element(id: _, action: .sendConfirmation(.sendTapped))):
                for element in state.path {
                    if case .sendConfirmation(let sendConfirmationState) = element {
                        state.path.append(.sending(sendConfirmationState))
                        break
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .sendConfirmation(.updateResult(let result)))),
                    .path(.element(id: _, action: .requestZecConfirmation(.updateResult(let result)))):
                for element in state.path {
                    if case .sending(let sendConfirmationState) = element {
                        switch result {
                        case .failure:
                            state.path.append(.sendResultFailure(sendConfirmationState))
                            break
                        case .partial:
                            var partialProposalErrorState = PartialProposalError.State.initial
                            partialProposalErrorState.statuses = sendConfirmationState.partialFailureStatuses
                            partialProposalErrorState.txIds = sendConfirmationState.partialFailureTxIds
                            state.path.append(.sendResultPartial(partialProposalErrorState))
                            break
                        case .resubmission:
                            state.path.append(.sendResultResubmission(sendConfirmationState))
                            break
                        case .success:
                            state.path.append(.sendResultSuccess(sendConfirmationState))
                        default: break
                        }
                    }
                }
                return .none

            case .path(.element(id: _, action: .sendResultFailure(.backFromFailureTapped))):
                state.path.removeAll()
                return .none

            case .path(.element(id: _, action: .preSendingFailure(.backFromPCZTFailureTapped))):
                state.path.removeAll()
                return .none

            case .path(.element(id: _, action: .sendResultSuccess(.viewTransactionTapped))),
                    .path(.element(id: _, action: .sendResultFailure(.viewTransactionTapped))),
                    .path(.element(id: _, action: .sendResultResubmission(.viewTransactionTapped))):
                var transactionDetailsState = TransactionDetails.State.initial
                for element in state.path {
                    if case .sendConfirmation(let sendConfirmationState) = element {
                        if let txid = sendConfirmationState.txIdToExpand {
                            if let index = state.transactions.index(id: txid) {
                                transactionDetailsState.transaction = state.transactions[index]
                                transactionDetailsState.isCloseButtonRequired = true
                                state.path.append(.transactionDetails(transactionDetailsState))
                                break
                            }
                        }
                    }
                }
                return .none
                
                // MARK: - Self

            case .dismissRequired:
                return .none

                // MARK: - Transaction Details
                
            case .path(.element(id: _, action: .transactionDetails(.saveAddressTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.address = state.sendFormState.address.data
                addressBookState.isNameFocused = true
                addressBookState.isValidZcashAddress = true
                state.path.append(.addressBookContact(addressBookState))
                return .none

            case .path(.element(id: _, action: .transactionDetails(.sendAgainTapped))):
                state.path.removeAll()
                return .none

            default: return .none
            }
        }
    }
}
