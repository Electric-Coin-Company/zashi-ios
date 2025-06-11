//
//  SwapAndPayCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import ComposableArchitecture
import Generated

// Path
import AddressBook
import SwapAndPayForm

extension SwapAndPayCoordFlow {
    public func coordinatorReduce() -> Reduce< SwapAndPayCoordFlow.State,  SwapAndPayCoordFlow.Action> {
        Reduce { state, action in
            switch action {

                // MARK: - Address Book Contact
                
//            case .path(.element(id: _, action: .addressBookContact(.dismissAddContactRequired))):
//                var addressBookState = AddressBook.State.initial
//                state.path.append(.addressBookChainToken(addressBookState))
//                return .none

                // MARK: - Self

//            case .addressBook(.addManualButtonTapped):
//                var addressBookState = AddressBook.State.initial
//                addressBookState.isAddressFocused = true
//                state.path.append(.addressBookContact(addressBookState))
//                return .none
//
//            case .addressBook(.editId(let address)):
//                audioServices.systemSoundVibrate()
//                // TODO: append ZecKeyboard here
//                print("TODO: append ZecKeyboard here")
//                return .none

//            case .swapAndPay(.nextTapped):
//                state.path.append(.swapAndPayForm(state.swapAndPayState))
//                return .none

            default: return .none
            }
        }
    }
}
