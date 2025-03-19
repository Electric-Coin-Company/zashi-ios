//
//  SendCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-18.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices
import Models

// Path
import AddressBook
import PartialProposalError
import Scan
import SendConfirmation
import SendForm
import TransactionDetails

@Reducer
public struct SendCoordFlow {
    @Reducer
    public enum Path {
        case addressBook(AddressBook)
        case addressBookContact(AddressBook)
        case preSendingFailure(SendConfirmation)
        case scan(Scan)
        case sendConfirmation(SendConfirmation)
        case sending(SendConfirmation)
        case sendResultFailure(SendConfirmation)
        case sendResultPartial(PartialProposalError)
        case sendResultResubmission(SendConfirmation)
        case sendResultSuccess(SendConfirmation)
        case transactionDetails(TransactionDetails)
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        public var sendFormState = SendForm.State.initial
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []

        public init() { }
    }

    public enum Action {
        case dismissRequired
        case path(StackActionOf<Path>)
        case sendForm(SendForm.Action)
    }

    @Dependency(\.audioServices) var audioServices

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.sendFormState, action: \.sendForm) {
            SendForm()
        }

        Reduce { state, action in
            switch action {
            case .dismissRequired:
                return .none
                
            case .sendForm:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
