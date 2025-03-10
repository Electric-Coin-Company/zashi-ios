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
import PrivateDataConsent
import Receive
import RecoveryPhraseDisplay
import RequestZec
import Scan
import SendFeedback
import SendFlow
import ServerSetup
import Settings
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
                    if case .integrations = element {
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
                for element in state.path {
                    if case .settings = element {
                        isAddressBookFromSettings = true
                        break
                    }
                }
                if isAddressBookFromSettings {
                    var addressBookContactState = AddressBook.State.initial
                    addressBookContactState.editId = address
                    addressBookContactState.isNameFocused = true
                    state.path.append(.addressBookContact(addressBookContactState))
                } else {
                    var sendFlowState = SendFlow.State.initial
                    sendFlowState.address = address.redacted
                    state.path.append(.sendFlow(sendFlowState))
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
                state.path.append(.addressBook(AddressBook.State.initial))
                return .none

            case .home(.flexaTapped):
                return .send(.flexaOpenRequest)
                
            case .home(.addKeystoneHWWalletTapped):
                state.path.append(.addKeystoneHWWallet(AddKeystoneHWWallet.State.initial))
                return .none

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
                    if case .addKeystoneHWWallet = element {
                        var addKeystoneHWWalletState = AddKeystoneHWWallet.State.initial
                        addKeystoneHWWalletState.zcashAccounts = account
                        state.path.append(.accountHWWalletSelection(addKeystoneHWWalletState))
                        break
                    }
                }
                return .none

                // MARK: - Send Flow
                
            case .path(.element(id: _, action: .sendFlow(.dismissRequired))):
                state.path.removeAll()
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

                // MARK: - Zec Keyboard

            case .path(.element(id: _, action: .zecKeyboard(.nextTapped))):
                for (_, element) in zip(state.path.ids, state.path) {
                    switch element {
                    case .zecKeyboard(let zecKeyboardState):
                        state.requestZecState.requestedZec = zecKeyboardState.amount
                    default: break
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

