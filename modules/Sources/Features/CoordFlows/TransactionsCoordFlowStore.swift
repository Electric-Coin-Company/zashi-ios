//
//  TransactionsCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-20.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import Models

// Path
import AddressBook
import TransactionDetails
import TransactionsManager

@Reducer
public struct TransactionsCoordFlow {
    @Reducer
    public enum Path {
        case addressBookContact(AddressBook)
        case transactionDetails(TransactionDetails)
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        public var transactionDetailsState = TransactionDetails.State.initial
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []
        public var transactionsManagerState = TransactionsManager.State.initial
        public var transactionToOpen: String?
        
        public init() { }
    }

    public enum Action {
        case path(StackActionOf<Path>)
        case transactionDetails(TransactionDetails.Action)
        case transactionsManager(TransactionsManager.Action)
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.transactionDetailsState, action: \.transactionDetails) {
            TransactionDetails()
        }
        
        Scope(state: \.transactionsManagerState, action: \.transactionsManager) {
            TransactionsManager()
        }
        
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
