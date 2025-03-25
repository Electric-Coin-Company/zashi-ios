//
//  ScanCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-19.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import ZcashPaymentURI

import Generated
import AudioServices

// Path
import AddressBook
import PartialProposalError
import Scan
import SendConfirmation
import SendForm
import TransactionDetails

extension ScanCoordFlow {
    public func coordinatorReduce() -> Reduce<ScanCoordFlow.State, ScanCoordFlow.Action> {
        Reduce { state, action in
            switch action {

                // MARK: - Address Book
                
            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                let _ = state.path.removeLast()
                audioServices.systemSoundVibrate()
                if let first = state.path.ids.first {
                    return .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address.redacted)))))
                }
                return .none

            case .path(.element(id: _, action: .addressBook(.walletAccountTapped(let contact)))):
                if let address = contact.uAddress?.stringEncoded {
                    let _ = state.path.removeLast()
                    audioServices.systemSoundVibrate()
                    if let first = state.path.ids.first {
                        return .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address.redacted)))))
                    }
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
                
                // handling the path in the transaction details
                for element in state.path {
                    if element.is(\.transactionDetails) {
                        return .none
                    }
                }

                // handling the path in send confirmation
                for element in state.path {
                    if element.is(\.sendConfirmation) {
                        return .none
                    }
                }

                // handling the path in send form
                for element in state.path {
                    if element.is(\.scan) {
                        let _ = state.path.popLast()
                        return .none
                    }
                }
                return .none
                
                // MARK: - Request ZEC Confirmation
                
            case .path(.element(id: _, action: .requestZecConfirmation(.goBackTappedFromRequestZec))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        state.path.pop(to: id)
                    }
                }
                return .none

            case .path(.element(id: _, action: .requestZecConfirmation(.sendTapped))):
                for element in state.path {
                    if case .requestZecConfirmation(let sendConfirmationState) = element {
                        state.path.append(.sending(sendConfirmationState))
                        break
                    }
                }
                return .none

            case .path(.element(id: _, action: .requestZecConfirmation(.saveAddressTapped(let address)))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isNameFocused = true
                addressBookState.address = address.data
                addressBookState.isValidZcashAddress = true
                state.path.append(.addressBookContact(addressBookState))
                return .none
                
            case .path(.element(id: _, action: .requestZecConfirmation(.updateResult(let result)))):
                for element in state.path {
                    if case .requestZecConfirmation(let sendConfirmationState) = element {
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
                
                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundAddress(let address)))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        let _ = state.path.removeLast()
                        audioServices.systemSoundVibrate()
                        return .send(.path(.element(id: id, action: .sendForm(.addressUpdated(address)))))
                    }
                }
                return .none

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none
                
            case .path(.element(id: _, action: .scan(.foundRequestZec(let requestPayment)))):
                if case .legacy(let address) = requestPayment {
                    for (id, element) in zip(state.path.ids, state.path) {
                        if element.is(\.sendForm) {
                            let _ = state.path.removeLast()
                            audioServices.systemSoundVibrate()
                            state.path[id: id, case: \.sendForm]?.memoState.text = ""
                            return .merge(
                                .send(.path(.element(id: id, action: .sendForm(.zecAmountUpdated("".redacted))))),
                                .send(.path(.element(id: id, action: .sendForm(.addressUpdated(address.value.redacted)))))
                            )
                        }
                    }
                } else if case .request(let paymentRequest) = requestPayment {
                    return .send(.getProposal(paymentRequest))
                }
                return .none
                
                // MARK: - Self
                
            case .scan(.foundAddress(let address)):
                audioServices.systemSoundVibrate()
                state.path.append(.sendForm(SendForm.State.initial))
                if let first = state.path.ids.first {
                    return .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address)))))
                }
                return .none

            case .scan(.foundRequestZec(let requestPayment)):
                if case .legacy(let address) = requestPayment {
                    return .send(.scan(.foundAddress(address.value.redacted)))
                } else if case .request(let paymentRequest) = requestPayment {
                    return .send(.getProposal(paymentRequest))
                }
                return .none
                
            case .getProposal(let paymentRequest):
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                
                do {
                    if let payment = paymentRequest.payments.first {
                        var textMemo = ""
                        if let memoBytes = payment.memo, let memo = try? Memo(bytes: [UInt8](memoBytes.memoData)) {
                            textMemo = memo.toString() ?? ""
                        }
                        let numberLocale = numberFormatter.convertUSToLocale(payment.amount.toString()) ?? ""
                        state.recipient = try Recipient(payment.recipientAddress.value, network: zcashSDKEnvironment.network.networkType)
                        state.memo = textMemo.isEmpty ? nil : try Memo(string: textMemo)
                        
                        if let number = numberFormatter.number(numberLocale) {
                            state.amount = Zatoshi(NSDecimalNumber(
                                decimal: number.decimalValue * Decimal(Zatoshi.Constants.oneZecInZatoshi)
                            ).roundedZec.int64Value)
                        }
                    }
                } catch {
                    return .send(.requestZecFailed)
                }
                
                return .run { [state] send in
                    guard let recipient = state.recipient else {
                        return
                    }
                    do {
                        let proposal = try await sdkSynchronizer.proposeTransfer(account.id, recipient, state.amount, state.memo)
                        await send(.proposalResolved(proposal))
                    } catch {
                        await send(.requestZecFailed)
                    }
                }
                
            case .proposalResolved(let proposal):
                if state.path.ids.isEmpty {
                    return .send(.proposalResolvedNoSendForm(proposal))
                }
                return .send(.proposalResolvedExistingSendForm(proposal))

            case .proposalResolvedExistingSendForm(let proposal):
                state.proposal = proposal
                
                guard let address = state.recipient?.stringEncoded else {
                    return .send(.requestZecFailed)
                }

                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.amount = state.amount
                sendConfirmationState.address = address
                sendConfirmationState.proposal = proposal
                sendConfirmationState.feeRequired = proposal.totalFeeRequired()
                sendConfirmationState.message = state.memo?.toString() ?? ""
                sendConfirmationState.currencyAmount = state.currencyConversion?.convert(state.amount).redacted ?? .empty
                state.path.append(.requestZecConfirmation(sendConfirmationState))
                
                audioServices.systemSoundVibrate()
                
                if let first = state.path.ids.first {
                    state.path[id: first, case: \.sendForm]?.memoState.text = sendConfirmationState.message
                    return .merge(
                        .send(.path(.element(id: first, action: .sendForm(.zecAmountUpdated(state.amount.decimalString().redacted))))),
                        .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address.redacted)))))
                    )
                }
                return .none

            case .proposalResolvedNoSendForm(let proposal):
                state.proposal = proposal
                
                guard let address = state.recipient?.stringEncoded else {
                    return .send(.requestZecFailed)
                }
                
                var sendFormState = SendForm.State.initial
                sendFormState.memoState.text = state.memo?.toString() ?? ""
                state.path.append(.sendForm(sendFormState))

                var sendConfirmationState = SendConfirmation.State.initial
                sendConfirmationState.amount = state.amount
                sendConfirmationState.address = address
                sendConfirmationState.proposal = proposal
                sendConfirmationState.feeRequired = proposal.totalFeeRequired()
                sendConfirmationState.message = sendFormState.memoState.text
                sendConfirmationState.currencyAmount = state.currencyConversion?.convert(state.amount).redacted ?? .empty
                state.path.append(.requestZecConfirmation(sendConfirmationState))
                
                audioServices.systemSoundVibrate()
                
                if let first = state.path.ids.first {
                    return .merge(
                        .send(.path(.element(id: first, action: .sendForm(.zecAmountUpdated(state.amount.decimalString().redacted))))),
                        .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address.redacted)))))
                    )
                }
                return .none

            case .requestZecFailed:
                if state.path.ids.isEmpty {
                    return .send(.requestZecFailedNoSendForm)
                }
                return .send(.requestZecFailedExistingSendForm)

            case .requestZecFailedExistingSendForm:
                let _ = state.path.removeLast()
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        audioServices.systemSoundVibrate()
                        
                        let address = state.recipient?.stringEncoded ?? ""
                        let memo = state.memo?.toString() ?? ""
                        state.path[id: id, case: \.sendForm]?.memoState.text = memo
                        return .merge(
                            .send(.path(.element(id: id, action: .sendForm(.zecAmountUpdated(state.amount.decimalString().redacted))))),
                            .send(.path(.element(id: id, action: .sendForm(.addressUpdated(address.redacted)))))
                        )
                    }
                }
                return .none

            case .requestZecFailedNoSendForm:
                let address = state.recipient?.stringEncoded ?? ""
                var sendFormState = SendForm.State.initial
                sendFormState.memoState.text = state.memo?.toString() ?? ""
                state.path.append(.sendForm(sendFormState))
                
                audioServices.systemSoundVibrate()
                
                if let first = state.path.ids.first {
                    return .merge(
                        .send(.path(.element(id: first, action: .sendForm(.zecAmountUpdated(state.amount.decimalString().redacted))))),
                        .send(.path(.element(id: first, action: .sendForm(.addressUpdated(address.redacted)))))
                    )
                }
                return .none

                // MARK: - Send

            case .path(.element(id: _, action: .sendForm(.addressBookTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isInSelectMode = true
                state.path.append(.addressBook(addressBookState))
                return .none
                
            case .path(.element(id: _, action: .sendForm(.addNewContactTapped(let address)))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isNameFocused = true
                addressBookState.address = address.data
                addressBookState.isValidZcashAddress = true
                state.path.append(.addressBookContact(addressBookState))
                return .none

            case .path(.element(id: _, action: .sendForm(.scanTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                state.path.append(.scan(scanState))
                return .none
                
            case .path(.element(id: _, action: .sendForm(.confirmationRequired(let confirmationType)))):
                for element in state.path {
                    if case .sendForm(let sendFormState) = element {
                        var sendConfirmationState = SendConfirmation.State.initial
                        sendConfirmationState.amount = sendFormState.amount
                        sendConfirmationState.address = sendFormState.address.data
                        sendConfirmationState.proposal = sendFormState.proposal
                        sendConfirmationState.feeRequired = sendFormState.feeRequired
                        sendConfirmationState.message = sendFormState.message
                        let currencyAmount = sendFormState.currencyConversion?.convert(sendFormState.amount).redacted ?? .empty
                        sendConfirmationState.currencyAmount = currencyAmount

                        if confirmationType == .send {
                            state.path.append(.sendConfirmation(sendConfirmationState))
                        }
                    }
                }
                return .none

                // MARK: - Send Confirmation
                
            case .path(.element(id: _, action: .sendConfirmation(.cancelTapped))):
                let _ = state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .sendConfirmation(.sendTapped))):
                for element in state.path {
                    if case .sendConfirmation(let sendConfirmationState) = element {
                        state.path.append(.sending(sendConfirmationState))
                        break
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .sendConfirmation(.updateResult(let result)))):
                for element in state.path {
                    if case .sendConfirmation(let sendConfirmationState) = element {
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

            case .path(.element(id: _, action: .sendResultFailure(.backFromFailureTapped))),
                    .path(.element(id: _, action: .preSendingFailure(.backFromPCZTFailureTapped))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        state.path.pop(to: id)
                    }
                }
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

                // MARK: - Transaction Details
                
            case .path(.element(id: _, action: .transactionDetails(.saveAddressTapped))):
                for element in state.path {
                    if case .transactionDetails(let transactionDetailsState) = element {
                        var addressBookState = AddressBook.State.initial
                        addressBookState.address = transactionDetailsState.transaction.address
                        addressBookState.isNameFocused = true
                        addressBookState.isValidZcashAddress = true
                        state.path.append(.addressBookContact(addressBookState))
                    }
                }
                return .none

            case .path(.element(id: _, action: .transactionDetails(.sendAgainTapped))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        state.path.pop(to: id)
                    }
                }
                return .none
                
                // MARK: -
                
                
                
                // Handling of scan inside address book
//                for element in state.path {
//                    if element.is(\.addressBook) {
//                        var addressBookState = AddressBook.State.initial
//                        addressBookState.address = address.data
//                        addressBookState.isValidZcashAddress = true
//                        addressBookState.isNameFocused = true
//                        state.path.append(.addressBookContact(addressBookState))
//                        audioServices.systemSoundVibrate()
//                        return .none
//                    }
//                }
//                // handling of scan for the send form
//                let _ = state.path.popLast()
//                audioServices.systemSoundVibrate()
//                return .send(.sendForm(.addressUpdated(address)))

//            case .scan(.foundRequestZec(let requestPayment)):
//                return .send(.sendForm(.requestZec(requestPayment)))

                /*
                // MARK: Address Book
                
            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                state.path.removeAll()
                audioServices.systemSoundVibrate()
                return .send(.sendForm(.addressUpdated(address.redacted)))

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

                // MARK: Address Book Contact

            case .path(.element(id: _, action: .addressBookContact(.dismissAddContactRequired))):
                let _ = state.path.popLast()
                for element in state.path {
                    if element.is(\.scan) {
                        let _ = state.path.popLast()
                        return .none
                    }
                }
                return .none
                
                // MARK: Request ZEC Confirmation
                
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
                
                

                // MARK: Send
                
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
                
                // MARK: Send Confirmation

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
                
                // MARK: Self

            case .dismissRequired:
                return .none

                // MARK: Transaction Details
                
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
*/
            default: return .none
            }
        }
    }
}
