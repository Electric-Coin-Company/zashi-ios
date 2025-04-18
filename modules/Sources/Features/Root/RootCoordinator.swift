//
//  RootCoordinator.swift
//  modules
//
//  Created by Lukáš Korba on 07.03.2025.
//

import ComposableArchitecture

extension Root {
    public func coordinatorReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
                
                // MARK: - Accounts

            case .home(.walletAccountTapped(let walletAccount)):
                guard state.selectedWalletAccount != walletAccount else {
                    return .none
                }
                state.$selectedWalletAccount.withLock { $0 = walletAccount }
                state.homeState.transactionListState.isInvalidated = true
                return .merge(
                    .send(.home(.smartBanner(.walletAccountChanged))),
                    .send(.home(.walletBalances(.updateBalances))),
                    .send(.loadContacts),
                    .send(.resolveMetadataEncryptionKeys),
                    .send(.loadUserMetadata),
                    .send(.fetchTransactionsForTheSelectedAccount)
                    //.send(.transactionsManager(.resetFiltersTapped))
                )

//                            case .walletAccountTapped(let walletAccount):
//                                state.accountSwitchRequest = false
//                                return .concatenate(
//                                    .send(.transactionsManager(.resetFiltersTapped))
//                                )

                
                // MARK: - Add Keystone HW Wallet Coord Flow

            case .addKeystoneHWWalletCoordFlow(.path(.element(id: _, action: .accountHWWalletSelection(.forgetThisDeviceTapped)))):
                state.path = nil
                return .none

            case .addKeystoneHWWalletCoordFlow(.path(.element(id: _, action: .accountHWWalletSelection(.accountImportSucceeded)))):
                state.path = nil
                return .merge(
                    .send(.loadContacts),
                    .send(.resolveMetadataEncryptionKeys),
                    .send(.loadUserMetadata),
                    .send(.fetchTransactionsForTheSelectedAccount)
                )

                // MARK: - Add Keystone HW Wallet from Settings

            case .settings(.path(.element(id: _, action: .accountHWWalletSelection(.accountImportSucceeded)))):
                state.path = nil
                return .merge(
                    .send(.loadContacts),
                    .send(.resolveMetadataEncryptionKeys),
                    .send(.loadUserMetadata),
                    .send(.fetchTransactionsForTheSelectedAccount)
                )
                
                // MARK: - Flexa

            case .flexaOpenRequest:
                flexaHandler.open()
                return .publisher {
                    flexaHandler.onTransactionRequest()
                        .map(Root.Action.flexaOnTransactionRequest)
                        .receive(on: mainQueue)
                }
                .cancellable(id: CancelFlexaId, cancelInFlight: true)
                
                // MARK: - Currency Conversion Setup
                
            case .currencyConversionSetup(.skipTapped), .currencyConversionSetup(.enableTapped):
                state.path = nil
                state.homeState.isRateEducationEnabled = false
                return .send(.home(.smartBanner(.closeAndCleanupBanner)))

                // MARK: - Home

            case .home(.settingsTapped):
                state.settingsState = .initial
                state.settingsState.uAddress = state.zashiUAddress
                state.path = .settings
                return .none
                
            case .home(.receiveTapped):
                state.receiveState = .initial
                state.path = .receive
                return .none

            case .home(.sendTapped):
                state.sendCoordFlowState = .initial
                state.path = .sendCoordFlow
                return .none

            case .home(.scanTapped):
                state.scanCoordFlowState = .initial
                state.path = .scanCoordFlow
                return .none

            case .home(.getSomeZecTapped):
                state.requestZecCoordFlowState = .initial
                state.path = .requestZecCoordFlow
                return .none
                
            case .home(.flexaTapped):
                return .send(.flexaOpenRequest)
                
            case .home(.addKeystoneHWWalletTapped):
                state.addKeystoneHWWalletCoordFlowState = .initial
                state.path = .addKeystoneHWWalletCoordFlow
                return .none
                
            case .home(.transactionList(.transactionTapped(let txId))):
                state.transactionsCoordFlowState = .initial
                state.transactionsCoordFlowState.transactionToOpen = txId
                if let index = state.transactions.index(id: txId) {
                    state.transactionsCoordFlowState.transactionDetailsState.transaction = state.transactions[index]
                }
                state.path = .transactionsCoordFlow
                return .none

            case .home(.seeAllTransactionsTapped):
                state.transactionsCoordFlowState = .initial
                state.path = .transactionsCoordFlow
                return .none
                
            case .home(.currencyConversionSetupTapped):
                state.currencyConversionSetupState = .initial
                state.path = .currencyConversionSetup
                return .none

                // MARK: - Integrations

            case .settings(.path(.element(id: _, action: .integrations(.flexaTapped)))):
                return .send(.flexaOpenRequest)
                
                // MARK: - Keystone

            case .sendCoordFlow(.path(.element(id: _, action: .confirmWithKeystone(.rejectTapped)))),
                    .signWithKeystoneCoordFlow(.sendConfirmation(.rejectTapped)):
                state.path = nil
                return .none
                
//            case .home(.balances(.proposalReadyForShieldingWithKeystone(let proposal))),
//                    .home(.shieldingProcessor(.proposalReadyForShieldingWithKeystone(let proposal))):
//            case .home(.shieldingProcessor(.proposalReadyForShieldingWithKeystone(let proposal))):
//                state.signWithKeystoneCoordFlowState = .initial
//                state.signWithKeystoneCoordFlowState.sendConfirmationState.proposal = proposal
//                state.signWithKeystoneCoordFlowState.sendConfirmationState.isShielding = true
//                state.homeState.balancesBinding = false
//                return .run { send in
//                    try? await mainQueue.sleep(for: .seconds(0.8))
//                    await send(.signWithKeystoneRequested)
//                }

            case .signWithKeystoneRequested:
                //state.path = .signWithKeystoneCoordFlow
                state.signWithKeystoneCoordFlowBinding = true
                return .send(.signWithKeystoneCoordFlow(.sendConfirmation(.resolvePCZT)))
                
                // MARK: - Request Zec

            case .requestZecCoordFlow(.path(.element(id: _, action: .requestZecSummary(.cancelRequestTapped)))):
                state.path = nil
                return .none

                // MARK: - Reset Zashi

            case .settings(.path(.element(id: _, action: .resetZashi(.deleteTapped)))):
                return .send(.initialization(.resetZashiRequest))

                // MARK: - Restore Wallet Coord Flow from Onboarding

            case .onboarding(.restoreWalletCoordFlow(.path(.element(id: _, action: .restoreInfo(.gotItTapped))))):
                var leavesScreenOpen = false
                for element in state.onboardingState.restoreWalletCoordFlowState.path {
                    if case .restoreInfo(let restoreInfoState) = element {
                        leavesScreenOpen = restoreInfoState.isAcknowledged
                    }
                }
                userDefaults.setValue(leavesScreenOpen, Constants.udLeavesScreenOpen)
                state.isRestoringWallet = true
                userDefaults.setValue(true, Constants.udIsRestoringWallet)
                state.$walletStatus.withLock { $0 = .restoring }
                return .concatenate(
                    .send(.initialization(.initializeSDK(.restoreWallet))),
                    .send(.initialization(.checkBackupPhraseValidation)),
                    .send(.batteryStateChanged(nil))
                )

                // MARK: - Scan Coord Flow
                
            case .scanCoordFlow(.scan(.cancelTapped)):
                state.path = nil
                return .none
                
            case .scanCoordFlow(.path(.element(id: _, action: .sendForm(.dismissRequired)))):
                state.path = nil
                return .none

            case .scanCoordFlow(.path(.element(id: _, action: .transactionDetails(.closeDetailTapped)))):
                state.path = nil
                return .none

            case .scanCoordFlow(.path(.element(id: _, action: .sendResultSuccess(.closeTapped)))),
                    .scanCoordFlow(.path(.element(id: _, action: .sendResultResubmission(.closeTapped)))),
                    .scanCoordFlow(.path(.element(id: _, action: .sendResultPartial(.dismiss)))):
                state.path = nil
                return .none

                // MARK: - Self
                
            case .sendAgainRequested(let transactionState):
                state.sendCoordFlowState = .initial
                state.path = .sendCoordFlow
                state.sendCoordFlowState.sendFormState.memoState.text = state.transactionMemos[transactionState.id]?.first ?? ""
                return .merge(
                    .send(.sendCoordFlow(.sendForm(.zecAmountUpdated(transactionState.amountWithoutFee.decimalString().redacted)))),
                    .send(.sendCoordFlow(.sendForm(.addressUpdated(transactionState.address.redacted))))
                )
                
            case .deeplinkWarning(.rescanInZashi):
                state = .initial
                state.splashAppeared = true
                return .merge(
                    .send(.destination(.updateDestination(.home))),
                    .send(.home(.scanTapped))
                )

                // MARK: - Send Coord Flow
                
            case .sendCoordFlow(.path(.element(id: _, action: .sendResultSuccess(.closeTapped)))),
                    .sendCoordFlow(.path(.element(id: _, action: .sendResultResubmission(.closeTapped)))),
                    .sendCoordFlow(.path(.element(id: _, action: .sendResultPartial(.dismiss)))):
                state.path = nil
                return .none

            case .sendCoordFlow(.path(.element(id: _, action: .transactionDetails(.closeDetailTapped)))):
                state.path = nil
                return .none

            case .sendCoordFlow(.dismissRequired):
                state.path = nil
                return .none

                // MARK: - Sign with Keystone Coord Flow

            case .signWithKeystoneCoordFlow(.path(.element(id: _, action: .sendResultSuccess(.closeTapped)))),
                    .signWithKeystoneCoordFlow(.path(.element(id: _, action: .sendResultResubmission(.closeTapped)))):
                state.signWithKeystoneCoordFlowBinding = false
                return .none

            case .signWithKeystoneCoordFlow(.path(.element(id: _, action: .transactionDetails(.closeDetailTapped)))):
                state.signWithKeystoneCoordFlowBinding = false
                return .none

                // MARK: - Transactions Coord Flow
                
            case .transactionsCoordFlow(.transactionDetails(.closeDetailTapped)):
                state.path = nil
                return .none

            case .transactionsCoordFlow(.transactionsManager(.dismissRequired)):
                state.path = nil
                return .none

            case .transactionsCoordFlow(.transactionDetails(.sendAgainTapped)):
                state.path = nil
                let transactionState = state.transactionsCoordFlowState.transactionDetailsState.transaction
                return .run { send in
                    try? await mainQueue.sleep(for: .seconds(0.8))
                    await send(.sendAgainRequested(transactionState))
                }
                
            case .transactionsCoordFlow(.path(.element(id: _, action: .transactionDetails(.sendAgainTapped)))):
                for element in state.transactionsCoordFlowState.path {
                    if case .transactionDetails(let transactionDetailsState) = element {
                        state.path = nil
                        return .run { send in
                            try? await mainQueue.sleep(for: .seconds(0.8))
                            await send(.sendAgainRequested(transactionDetailsState.transaction))
                        }
                    }
                }
                return .none

            default: return .none
            }
        }
    }
}

/*
import ComposableArchitecture
import Generated
//import ZcashLightClientKit

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

            case .path(.element(id: _, action: .addressBookContact(.dismissDeleteContactRequired))):
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

            case .home(.settingsTapped):
//                state.path.append(.settings(Settings.State.initial))
                state.settingsBinding = true
                return .none

            case .home(.receiveTapped):
                state.path.append(.receive(Receive.State.initial))
                return .none

            case .home(.sendTapped):
                state.path.append(.sendForm(SendForm.State.initial))
                return .none

            case .home(.scanTapped):
                var scanState = Scan.State.initial
                scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                state.path.append(.scan(scanState))
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

            case .settings(.path(.element(id: _, action: .integrations(.flexaTapped)))):
                return .send(.flexaOpenRequest)
                
//            case .path(.element(id: _, action: .integrations(.flexaTapped))):
//                return .send(.flexaOpenRequest)
//
//            case .path(.element(id: _, action: .integrations(.keystoneTapped))):
//                state.path.append(.addKeystoneHWWallet(AddKeystoneHWWallet.State.initial))
//                return .none

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
                        audioServices.systemSoundVibrate()
                        break
                    }
                }
                return .none

            case .path(.element(id: _, action: .scan(.found(let address)))):
                // Handling of scan used in address book to add a contact
                // This handling must preceed the next one with Send Form check
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
                // Handling of scan used in the Send Form
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.sendForm) {
                        state.path[id: id, case: \.sendForm]?.address = address
                        state.path[id: id, case: \.sendForm]?.isValidAddress = true
                        state.path[id: id, case: \.sendForm]?.isValidTransparentAddress = derivationTool.isTransparentAddress(
                            address.data,
                            zcashSDKEnvironment.network.networkType
                        )
                        state.path[id: id, case: \.sendForm]?.isValidTexAddress = derivationTool.isTexAddress(
                            address.data,
                            zcashSDKEnvironment.network.networkType
                        )
                        audioServices.systemSoundVibrate()
                        let _ = state.path.popLast()
                        return .none
                    }
                }
                // Scan from Home
                if state.path.ids.count == 1 {
//                    var sendFormState = SendForm.State.initial
//                    sendFormState.address = address
//                    sendFormState.isValidAddress = true
//                    sendFormState.isValidTransparentAddress = derivationTool.isTransparentAddress(
//                        address.data,
//                        zcashSDKEnvironment.network.networkType
//                    )
//                    sendFormState.isValidTexAddress = derivationTool.isTexAddress(
//                        address.data,
//                        zcashSDKEnvironment.network.networkType
//                    )
//
//                    state.path.append(.sendForm(sendFormState))
                    audioServices.systemSoundVibrate()
                    state.path.append(.sendForm(SendForm.State.initial))
                    if let id = state.path.ids.last {
                        return .send(.path(.element(id: id, action: .sendForm(.addressUpdated(address)))))
                    }
                }
                return .none
                
//            case .path(.element(id: _, action: .scan(.foundRP(let requestPayment)))):
//                for (id, element) in zip(state.path.ids, state.path) {
//                    if element.is(\.sendForm) {
//                        if case .legacy(let address) = requestPayment {
//                            var sendFormState = SendForm.State.initial
//                            sendFormState.address = address.value.redacted
//                            sendFormState.isValidAddress = true
//                            sendFormState.isValidTransparentAddress = derivationTool.isTransparentAddress(
//                                address.value,
//                                zcashSDKEnvironment.network.networkType
//                            )
//                            sendFormState.isValidTexAddress = derivationTool.isTexAddress(
//                                address.value,
//                                zcashSDKEnvironment.network.networkType
//                            )
//                            
//                            state.path.append(.sendForm(sendFormState))
//                            audioServices.systemSoundVibrate()
//                        } else if case .request(let paymentRequest) = requestPayment {
//                            if let payment = paymentRequest.payments.first {
//                                //                        if let memoBytes = payment.memo, let memo = try? Memo(bytes: [UInt8](memoBytes.memoData)) {
//                                //                            state.memoState.text = memo.toString() ?? ""
//                                //                        }
//                                //                        let numberLocale = numberFormatter.convertUSToLocale(payment.amount.toString()) ?? ""
//                                //                        state.address = payment.recipientAddress.value.redacted
//                                //                        state.zecAmountText = numberLocale.redacted
//                                //                        audioServices.systemSoundVibrate()
//                            }
//                        }
//                    }
//                }
//                // Scan from Home
//                if state.path.ids.count == 1 {
//                    if case .legacy(let address) = requestPayment {
//                        var sendFormState = SendForm.State.initial
//                        sendFormState.address = address.value.redacted
//                        sendFormState.isValidAddress = true
//                        sendFormState.isValidTransparentAddress = derivationTool.isTransparentAddress(
//                            address.value,
//                            zcashSDKEnvironment.network.networkType
//                        )
//                        sendFormState.isValidTexAddress = derivationTool.isTexAddress(
//                            address.value,
//                            zcashSDKEnvironment.network.networkType
//                        )
//                        
//                        state.path.append(.sendForm(sendFormState))
//                        audioServices.systemSoundVibrate()
//                    } else if case .request(let paymentRequest) = requestPayment {
//                        if let payment = paymentRequest.payments.first {
//                            let address = payment.recipientAddress.value.redacted
//                            var sendFormState = SendForm.State.initial
//                            sendFormState.address = address
//                            sendFormState.isValidAddress = true
//                            sendFormState.isValidTransparentAddress = derivationTool.isTransparentAddress(
//                                address.data,
//                                zcashSDKEnvironment.network.networkType
//                            )
//                            sendFormState.isValidTexAddress = derivationTool.isTexAddress(
//                                address.data,
//                                zcashSDKEnvironment.network.networkType
//                            )
//
//                            if let memoBytes = payment.memo, let memo = try? Memo(bytes: [UInt8](memoBytes.memoData)) {
//                                sendFormState.memoState.text = memo.toString() ?? ""
//                            }
//                            let numberLocale = numberFormatter.convertUSToLocale(payment.amount.toString()) ?? ""
//                            sendFormState.zecAmountText = numberLocale.redacted
//                            audioServices.systemSoundVibrate()
//                            state.path.append(.sendForm(sendFormState))
//                            if let id = state.path.ids.last {
//                                return .send(.path(.element(id: id, action: .sendForm(.getProposal(.requestPayment)))))
//                            }
//                        }
//                    }
//                }
//                return .none

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
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
                
            case .path(.element(id: _, action: .sendForm(.scanTapped))):
                var scanState = Scan.State.initial
                scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                state.path.append(.scan(scanState))
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

//                 MARK: - Settings
//
//            case .path(.element(id: _, action: .settings(.addressBookTapped))):
//                state.path.append(.addressBook(AddressBook.State.initial))
//                return .none
//
//            case .path(.element(id: _, action: .settings(.integrationsTapped))):
//                var integrationsState = Integrations.State.initial
//                integrationsState.uAddress = state.zashiUAddress
//                state.path.append(.integrations(integrationsState))
//                return .none
//
//            case .path(.element(id: _, action: .settings(.advancedSettingsTapped))):
//                state.path.append(.advancedSettings(AdvancedSettings.State.initial))
//                return .none
//
//            case .path(.element(id: _, action: .settings(.whatsNewTapped))):
////                state.path.append(.whatsNew(WhatsNew.State.initial))
//                return .none
//
//            case .path(.element(id: _, action: .settings(.aboutTapped))):
//                state.path.append(.about(About.State.initial))
//                return .none
//
//            case .path(.element(id: _, action: .settings(.sendUsFeedbackTapped))):
//                state.path.append(.sendUsFeedback(SendFeedback.State.initial))
//                return .none

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
*/
