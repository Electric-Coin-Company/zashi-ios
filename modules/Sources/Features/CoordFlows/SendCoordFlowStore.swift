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

// Path
import AddressBook
import Scan
import SendForm

@Reducer
public struct SendCoordFlow {
    @Reducer
    public enum Path {
        case addressBook(AddressBook)
        case addressBookContact(AddressBook)
        case scan(Scan)
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
        public var sendFormState = SendForm.State.initial

        public init() { }
    }

    public enum Action {
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
            case .sendForm:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
