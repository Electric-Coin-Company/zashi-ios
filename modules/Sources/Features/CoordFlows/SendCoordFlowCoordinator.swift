//
//  SendCoordFlowCoordinator.swift
//  modules
//
//  Created by Lukáš Korba on 2025-03-18.
//

import ComposableArchitecture
import Generated
import AudioServices

import AddressBook
import Scan
import SendForm

extension SendCoordFlow {
    public func coordinatorReduce() -> Reduce<SendCoordFlow.State, SendCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Address Book
                
            case .path(.element(id: _, action: .addressBook(.editId(let address)))):
                state.path.removeAll()
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
                
                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundAddress(let address)))):
                for element in state.path {
                    if element.is(\.addressBook) {
                        var addressBookState = AddressBook.State.initial
                        addressBookState.address = address.data
                        addressBookState.isValidZcashAddress = true
                        addressBookState.isNameFocused = true
                        state.path.append(.addressBookContact(addressBookState))
                        audioServices.systemSoundVibrate()
                    }
                }
                return .none

                // MARK: - Send
                
            case .sendForm(.addressBookTapped):
                var addressBookState = AddressBook.State.initial
                addressBookState.isInSelectMode = true
                state.path.append(.addressBook(addressBookState))
                return .none
                
            default: return .none
            }
        }
    }
}
