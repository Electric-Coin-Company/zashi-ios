//
//  TransactionDetailsStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 01-08-2024
//

import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import Utils
import Models
import Generated
import Pasteboard
import SDKSynchronizer
import ReadTransactionsStorage
import ZcashSDKEnvironment
import AddressBookClient
import UIComponents

@Reducer
public struct TransactionDetails {
    @ObservableState
    public struct State: Equatable {
        public var areDetailsExpanded = false
        public var isMessageExpanded = false
        public var transaction: TransactionState
        
        public init(
            transaction: TransactionState
        ) {
            self.transaction = transaction
        }
    }
    
    public enum Action: Equatable {
        case bookmarkTapped
        case messageTapped
        case onAppear
        case sentToRowTapped
    }

    @Dependency(\.sdkSynchronizer) var sdkSynchronizer

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.areDetailsExpanded = false
                state.isMessageExpanded = false
                return .none
                
            case .bookmarkTapped:
                return .none

            case .messageTapped:
                state.isMessageExpanded.toggle()
                return .none

            case .sentToRowTapped:
                state.areDetailsExpanded.toggle()
                return .none
            }
        }
    }
}
