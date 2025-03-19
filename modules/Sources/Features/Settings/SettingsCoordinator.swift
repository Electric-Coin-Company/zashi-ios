//
//  SettingsCoordinator.swift
//  modules
//
//  Created by Lukáš Korba on 2025-03-17.
//

import ComposableArchitecture
import Generated

import About
import AddKeystoneHWWallet
import AddressBook
import CurrencyConversionSetup
import DeleteWallet
import ExportTransactionHistory
import PrivateDataConsent
import RecoveryPhraseDisplay
import Scan
import ServerSetup
import SendFeedback
import WhatsNew

extension Settings {
    public func coordinatorReduce() -> Reduce<Settings.State, Settings.Action> {
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
                for (id, element) in zip(state.path.ids, state.path) {
                    if element.is(\.integrations) {
                        state.path.pop(to: id)
                        break
                    }
                }
                return .none

//            case .path(.element(id: _, action: .accountHWWalletSelection(.accountImportSucceeded))):
                //state.path.removeAll()
//                return .none
//                return .merge(
//                    .send(.loadContacts),
//                    .send(.resolveMetadataEncryptionKeys),
//                    .send(.loadUserMetadata)
//                )
                
                // MARK: - Address Book

            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                var addressBookContactState = AddressBook.State.initial
                addressBookContactState.editId = address
                addressBookContactState.isNameFocused = true
                state.path.append(.addressBookContact(addressBookContactState))
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
                
                // MARK: - Integrations

            case .path(.element(id: _, action: .integrations(.keystoneTapped))):
                state.path.append(.addKeystoneHWWallet(AddKeystoneHWWallet.State.initial))
                return .none

                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundAccounts(let account)))):
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
                
            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none
                
                // MARK: - Settings

            case .addressBookTapped:
                state.path.append(.addressBook(AddressBook.State.initial))
                return .none

            case .integrationsTapped:
                var integrationsState = Integrations.State.initial
                integrationsState.uAddress = state.uAddress
                state.path.append(.integrations(integrationsState))
                return .none

            case .advancedSettingsTapped:
                state.path.append(.advancedSettings(AdvancedSettings.State.initial))
                return .none

            case .whatsNewTapped:
                state.path.append(.whatsNew(WhatsNew.State.initial))
                return .none

            case .aboutTapped:
                state.path.append(.about(About.State.initial))
                return .none

            case .sendUsFeedbackTapped:
                state.path.append(.sendUsFeedback(SendFeedback.State.initial))
                return .none
                
            default: return .none
            }
        }
    }
}
