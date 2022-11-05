//
//  AddressDetailsStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.07.2022.
//

import Foundation
import ComposableArchitecture

typealias AddressDetailsStore = Store<AddressDetailsReducer.State, AddressDetailsReducer.Action>

struct AddressDetailsReducer: ReducerProtocol {
    struct State: Equatable { }

    enum Action: Equatable {
        case copyToPastboard(String)
    }
    
    @Dependency(\.pasteboard) var pasteboard
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .copyToPastboard(let value):
            pasteboard.setString(value)
        }
        return .none
    }
}

// MARK: - Placeholders

extension AddressDetailsReducer.State {
    static let placeholder = AddressDetailsReducer.State()
}

extension AddressDetailsStore {
    static let placeholder = AddressDetailsStore(
        initialState: .placeholder,
        reducer: AddressDetailsReducer()
    )
}
