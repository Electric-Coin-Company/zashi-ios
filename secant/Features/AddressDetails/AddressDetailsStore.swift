//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import ComposableArchitecture

typealias AddressDetailsReducer = Reducer<AddressDetailsState, AddressDetailsAction, AddressDetailsEnvironment>
typealias AddressDetailsStore = Store<AddressDetailsState, AddressDetailsAction>
typealias AddressDetailsViewStore = ViewStore<AddressDetailsState, AddressDetailsAction>

// MARK: - State

struct AddressDetailsState: Equatable {
}

// MARK: - Action

enum AddressDetailsAction: Equatable {
    case copyToPastboard(String)
}

// MARK: - Environment

struct AddressDetailsEnvironment {
    let pasteboard: WrappedPasteboard
}

extension AddressDetailsEnvironment {
    static let live = AddressDetailsEnvironment(
        pasteboard: .live
    )

    static let mock = AddressDetailsEnvironment(
        pasteboard: .test
    )
}

// MARK: - Reducer

extension AddressDetailsReducer {
    static let `default` = AddressDetailsReducer { _, action, environment in
        switch action {
        case .copyToPastboard(let value):
            environment.pasteboard.setString(value)
        }
        
        return .none
    }
}

// MARK: - Store

extension AddressDetailsStore {
}

// MARK: - ViewStore

extension AddressDetailsViewStore {
}

// MARK: - Placeholders

extension AddressDetailsState {
    static let placeholder = AddressDetailsState(
    )
}

extension AddressDetailsStore {
    static let placeholder = AddressDetailsStore(
        initialState: .placeholder,
        reducer: .default,
        environment: AddressDetailsEnvironment(
            pasteboard: .test
        )
    )
}
