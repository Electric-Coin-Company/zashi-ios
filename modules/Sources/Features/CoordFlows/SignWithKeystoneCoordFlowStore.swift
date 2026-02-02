//
//  SignWithKeystoneCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-26.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices
import Models
import WalletStorage

// Path
import SendConfirmation
import Scan
import TransactionDetails

@Reducer
public struct SignWithKeystoneCoordFlow {
    @Reducer
    public enum Path {
        case preSendingFailure(SendConfirmation)
        case scan(Scan)
        case sending(SendConfirmation)
        case sendResultFailure(SendConfirmation)
        case sendResultPending(SendConfirmation)
        case sendResultSuccess(SendConfirmation)
        case transactionDetails(TransactionDetails)
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        public var sendConfirmationState = SendConfirmation.State.initial
        @Shared(.inMemory(.transactions)) public var transactions: IdentifiedArrayOf<TransactionState> = []

        public init() { }
    }

    public enum Action {
        case path(StackActionOf<Path>)
        case sendConfirmation(SendConfirmation.Action)
    }

    @Dependency(\.audioServices) var audioServices
    @Dependency(\.walletStorage) var walletStorage

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.sendConfirmationState, action: \.sendConfirmation) {
            SendConfirmation()
        }
        
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
