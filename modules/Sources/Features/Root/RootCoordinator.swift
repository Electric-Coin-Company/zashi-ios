//
//  RootCoordinator.swift
//  modules
//
//  Created by Lukáš Korba on 07.03.2025.
//

import ComposableArchitecture
import Generated

import About
import AddKeystoneHWWallet
import AddressBook
import AddressDetails
import CurrencyConversionSetup
import DeleteWallet
import ExportTransactionHistory
import PartialProposalError
import PrivateDataConsent
import Receive
import RecoveryPhraseDisplay
import RequestZec
import Scan
import SendConfirmation
import SendFeedback
import SendForm
import ServerSetup
import Settings
import TransactionDetails
import TransactionsManager
import WhatsNew
import ZecKeyboard

extension Root {
    public func coordinatorReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - Add Keystone HW Wallet

            case .path(.element(id: _, action: .addKeystoneHWWallet(.readyToScanTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.keystoneScanChecker]
                scanState.instructions = L10n.Keystone.scanInfo
                scanState.forceLibraryToHide = true
                state.path.append(.scan(scanState))
                return .none

            case .path(.element(id: _, action: .accountHWWalletSelection(.forgetThisDeviceTapped))):
                var isIntegrationsFlow = false
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.integrations) {
                        isIntegrationsFlow = true
                        state.path.pop(to: id)
                        break
                    }
                }
                if !isIntegrationsFlow {
                    state.path.removeAll()
                }
                return .none

            case .path(.element(id: _, action: .accountHWWalletSelection(.accountImportSucceeded))):
                state.path.removeAll()
                return .merge(
                    .send(.loadContacts),
                    .send(.resolveMetadataEncryptionKeys),
                    .send(.loadUserMetadata)
                )
                       
                // MARK: - Address Book

            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                var isAddressBookFromSettings = false
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.settings) {
                        isAddressBookFromSettings = true
                    }
                    if element.is(\.sendForm) {
                        state.path[id: id, case: \.sendForm]?.address = address.redacted
                        state.path[id: id, case: \.sendForm]?.isValidAddress = true
                        state.path[id: id, case: \.sendForm]?.isValidTransparentAddress = derivationTool.isTransparentAddress(
                            address,
                            zcashSDKEnvironment.network.networkType
                        )
                        state.path[id: id, case: \.sendForm]?.isValidTexAddress = derivationTool.isTexAddress(
                            address,
                            zcashSDKEnvironment.network.networkType
                        )
                        audioServices.systemSoundVibrate()
                        let _ = state.path.popLast()
                        return .none
                    }
                }
                if isAddressBookFromSettings {
                    var addressBookContactState = AddressBook.State.initial
                    addressBookContactState.editId = address
                    addressBookContactState.isNameFocused = true
                    state.path.append(.addressBookContact(addressBookContactState))
                } else {
                    var sendFormState = SendForm.State.initial
                    sendFormState.address = address.redacted
                    state.path.append(.sendForm(sendFormState))
                }
                return .none

            case .path(.element(id: _, action: .addressBook(.addManualButtonTapped))):
                state.path.append(.addressBookContact(AddressBook.State.initial))
                return .none

                // MARK: - Address Book Contact
                
            case .path(.element(id: _, action: .addressBookContact(.dismissAddContactRequired))):
                let _ = state.path.popLast()
                return .none

                // MARK: - Advanced Settings

            case .path(.element(id: _, action: .advancedSettings(.operationAccessGranted(let operation)))):
                switch operation {
                case .recoveryPhrase:
                    var recoveryPhraseDisplayState = RecoveryPhraseDisplay.State.initial
                    recoveryPhraseDisplayState.showBackButton = true
                    state.path.append(.recoveryPhrase(recoveryPhraseDisplayState))
                case .exportPrivateData:
                    state.path.append(.exportPrivateData(PrivateDataConsent.State.initial))
                case .exportTaxFile:
                    state.path.append(.exportTransactionHistory(ExportTransactionHistory.State.initial))
                case .chooseServer:
                    state.path.append(.chooseServerSetup(ServerSetup.State.initial))
                case .currencyConversion:
                    var currencyConversionSetupState = CurrencyConversionSetup.State.initial
                    currencyConversionSetupState.isSettingsView = true
                    state.path.append(.currencyConversionSetup(currencyConversionSetupState))
                case .resetZashi:
                    state.path.append(.resetZashi(DeleteWallet.State.initial))
                }
                return .none

                // MARK: - Flexa

            case .flexaOpenRequest:
                flexaHandler.open()
                return .publisher {
                    flexaHandler.onTransactionRequest()
                        .map(Root.Action.flexaOnTransactionRequest)
                        .receive(on: mainQueue)
                }
                .cancellable(id: CancelFlexaId, cancelInFlight: true)

                // MARK: - Home
                
            case .home(.receiveTapped):
                state.path.append(.receive(Receive.State.initial))
                return .none
                
            case .home(.settingsTapped):
                state.path.append(.settings(Settings.State.initial))
                return .none

            case .home(.sendTapped):
                state.path.append(.sendForm(SendForm.State.initial))
                return .none

            case .home(.flexaTapped):
                return .send(.flexaOpenRequest)
                
            case .home(.addKeystoneHWWalletTapped):
                state.path.append(.addKeystoneHWWallet(AddKeystoneHWWallet.State.initial))
                return .none

            case .home(.seeAllTransactionsTapped):
                state.path.append(.transactionsManager(TransactionsManager.State.initial))
                return .none

            case .home(.transactionList(.transactionTapped(let txId))):
                return .send(.transactionDetailsOpen(txId))

                // MARK: - Integrations

            case .path(.element(id: _, action: .integrations(.flexaTapped))):
                return .send(.flexaOpenRequest)

            case .path(.element(id: _, action: .integrations(.keystoneTapped))):
                state.path.append(.addKeystoneHWWallet(AddKeystoneHWWallet.State.initial))
                return .none

                // MARK: - Receive

            case let .path(.element(id: _, action: .receive(.addressDetailsRequest(address, maxPrivacy)))):
                var addressDetailsState = AddressDetails.State.initial
                addressDetailsState.address = address
                addressDetailsState.maxPrivacy = maxPrivacy
                if state.selectedWalletAccount?.vendor == .keystone {
                    addressDetailsState.addressTitle = maxPrivacy
                    ? L10n.Accounts.Keystone.shieldedAddress
                    : L10n.Accounts.Keystone.transparentAddress
                } else {
                    addressDetailsState.addressTitle = maxPrivacy
                    ? L10n.Accounts.Zashi.shieldedAddress
                    : L10n.Accounts.Zashi.transparentAddress
                }
                state.path.append(.addressDetails(addressDetailsState))
                return .none
                
            case let .path(.element(id: _, action: .receive(.requestTapped(address, maxPrivacy)))):
                var zecKeyboardState = ZecKeyboard.State.initial
                zecKeyboardState.input = "0"
                state.path.append(.zecKeyboard(zecKeyboardState))
                state.requestZecState = RequestZec.State.initial
                state.requestZecState.address = address
                state.requestZecState.maxPrivacy = maxPrivacy
                state.requestZecState.memoState = .initial
                return .none

                // MARK: - Request Zec

            case .path(.element(id: _, action: .requestZec(.requestTapped))):
                state.path.append(.requestZecSummary(state.requestZecState))
                return .none

            case .path(.element(id: _, action: .requestZecSummary(.cancelRequestTapped))):
                state.path.removeAll()
                return .none

                // MARK: - Reset Zashi

            case .path(.element(id: _, action: .resetZashi(.deleteTapped))):
                return .send(.initialization(.resetZashiRequest))

                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundZA(let account)))):
                for element in state.path {
                    if element.is(\.addKeystoneHWWallet) {
                        var addKeystoneHWWalletState = AddKeystoneHWWallet.State.initial
                        addKeystoneHWWalletState.zcashAccounts = account
                        state.path.append(.accountHWWalletSelection(addKeystoneHWWalletState))
                        break
                    }
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
                        break
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .sendResultSuccess(.closeTapped))):
                state.path.removeAll()
                return .none
                
            case .path(.element(id: _, action: .sendResultSuccess(.backFromFailureTapped))):
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        state.path.pop(to: id)
                        break
                    }
                }
                return .none

            case .path(.element(id: _, action: .sendResultSuccess(.viewTransactionTapped))):
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

                // MARK: - Send Form
                
            case .path(.element(id: _, action: .sendForm(.dismissRequired))):
                var popToRoot = true
                for element in state.path {
                    if element.is(\.transactionDetails) {
                        popToRoot = false
                        break
                    }
                }
                if popToRoot {
                    state.path.removeAll()
                } else {
                    let _ = state.path.popLast()
                }
                return .none

            case .path(.element(id: _, action: .sendForm(.addressBookTapped))):
                var addressBookState = AddressBook.State.initial
                addressBookState.isInSelectMode = true
                state.path.append(.addressBook(addressBookState))
                return .none

            case .path(.element(id: _, action: .sendForm(.confirmationRequired(let confirmationType)))):
                var sendConfirmationState = SendConfirmation.State.initial
                for element in state.path.reversed() {
                    if case .sendForm(let sendState) = element {
                        sendConfirmationState.amount = sendState.amount
                        sendConfirmationState.address = sendState.address.data
                        sendConfirmationState.isShielding = false
                        sendConfirmationState.proposal = sendState.proposal
                        sendConfirmationState.feeRequired = sendState.feeRequired
                        sendConfirmationState.message = sendState.message
                        sendConfirmationState.currencyAmount = sendState.currencyConversion?.convert(sendState.amount).redacted ?? .empty
                        break
                    }
                }
                if confirmationType == .send {
                    state.path.append(.sendConfirmation(sendConfirmationState))
                }
                return .none

                // MARK: - Settings

            case .path(.element(id: _, action: .settings(.addressBookTapped))):
                state.path.append(.addressBook(AddressBook.State.initial))
                return .none

            case .path(.element(id: _, action: .settings(.integrationsTapped))):
                var integrationsState = Integrations.State.initial
                integrationsState.uAddress = state.zashiUAddress
                state.path.append(.integrations(integrationsState))
                return .none

            case .path(.element(id: _, action: .settings(.advancedSettingsTapped))):
                state.path.append(.advancedSettings(AdvancedSettings.State.initial))
                return .none

            case .path(.element(id: _, action: .settings(.whatsNewTapped))):
                state.path.append(.whatsNew(WhatsNew.State.initial))
                return .none

            case .path(.element(id: _, action: .settings(.aboutTapped))):
                state.path.append(.about(About.State.initial))
                return .none

            case .path(.element(id: _, action: .settings(.sendUsFeedbackTapped))):
                state.path.append(.sendUsFeedback(SendFeedback.State.initial))
                return .none

                // MARK: - Transaction Details

            case .transactionDetailsOpen(let txId):
                var transactionDetailsState = TransactionDetails.State.initial
                if let index = state.transactions.index(id: txId) {
                    transactionDetailsState.transaction = state.transactions[index]
                }
                state.path.append(.transactionDetails(transactionDetailsState))
                return .none

            case .path(.element(id: _, action: .transactionDetails(.saveAddressTapped))):
                for element in state.path {
                    if case .transactionDetails(let transactionDetailsState) = element {
                        var addressBookState = AddressBook.State.initial
                        addressBookState.address = transactionDetailsState.transaction.address
                        addressBookState.isNameFocused = true
                        addressBookState.isValidZcashAddress = true
                        state.path.append(.addressBookContact(addressBookState))
                        break
                    }
                }
                return .none
                
            case .path(.element(id: _, action: .transactionDetails(.sendAgainTapped))):
                for element in state.path {
                    if case .transactionDetails(let transactionDetailsState) = element {
                        var sendFormState = SendForm.State.initial
                        sendFormState.address = transactionDetailsState.transaction.address.redacted
                        sendFormState.isValidAddress = true
                        sendFormState.zecAmountText = transactionDetailsState.transaction.amountWithoutFee.decimalString().redacted
                        sendFormState.memoState.text = state.transactionMemos[transactionDetailsState.transaction.id]?.first ?? ""
                        state.path.append(.sendForm(sendFormState))
                        break
                    }
                }
                return .none

            case .path(.element(id: _, action: .transactionDetails(.closeDetailTapped))):
                state.path.removeAll()
                return .none

                // MARK: - Transactions Manager

            case .path(.element(id: _, action: .transactionsManager(.transactionTapped(let txId)))):
                return .send(.transactionDetailsOpen(txId))

                // MARK: - Zec Keyboard

            case .path(.element(id: _, action: .zecKeyboard(.nextTapped))):
                for element in state.path {
                    if case .zecKeyboard(let zecKeyboardState) = element {
                        state.requestZecState.requestedZec = zecKeyboardState.amount
                        break
                    }
                }
                state.path.append(.requestZec(state.requestZecState))
                return .none

            case .path:
                return .none

            default: return .none
            }
        }
    }
}


//for (_, element) in zip(state.path.ids, state.path) {
//    switch element {
//    case .zecKeyboard(let zecKeyboardState):
//        state.requestZecState.requestedZec = zecKeyboardState.amount
//    default: break
//    }
//}
