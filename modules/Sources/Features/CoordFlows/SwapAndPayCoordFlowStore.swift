//
//  SwapAndPayCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices
import Models

// Path
import AddressBook
import Scan

@Reducer
public struct SwapAndPayCoordFlow {
    @Reducer
    public enum Path {
        case addressBookChainToken(AddressBook)
        case addressBookContact(AddressBook)
        case scan(Scan)
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        public var addressBookState = AddressBook.State.initial

        public init() { }
    }

    public enum Action {
        case path(StackActionOf<Path>)
        case addressBook(AddressBook.Action)
    }

    @Dependency(\.audioServices) var audioServices

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }

        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
