//
//  RootCoordinator.swift
//  modules
//
//  Created by Lukáš Korba on 07.03.2025.
//

import ComposableArchitecture
import Generated

import About
import AddressBook
import AddressDetails
import Receive
import RequestZec
import SendFeedback
import SendFlow
import Settings
import WhatsNew
import ZecKeyboard

extension Root {
    public func coordinatorReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
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

                // MARK: - Send Flow
                
            case .path(.element(id: _, action: .sendFlow(.dismissRequired))):
                state.path.removeAll()
                return .none

                // MARK: - Settings

            case .path(.element(id: _, action: .settings(.addressBookTapped))):
                state.path.append(.addressBook(AddressBook.State.initial))
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
    
//    private func path(for definedPath: Root.Path.State, state: Root.State) -> Root.Path.State? {
//        for (_, element) in zip(state.path.ids, state.path) {
//            if case definedPath = element {
//                
//            }
//            switch element {
//            case .zecKeyboard(let zecKeyboardState):
//                
//            default: break
//            }
//        }
//    }
}

