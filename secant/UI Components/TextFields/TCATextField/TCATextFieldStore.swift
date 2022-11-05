//
//  TextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

typealias TCATextFieldStore = Store<TCATextFieldReducer.State, TCATextFieldReducer.Action>

struct TCATextFieldReducer: ReducerProtocol {
    struct State: Equatable {
        var validationType: String.ValidationType?
        var text: String
        var valid = false

        init(validationType: String.ValidationType?, text: String) {
            self.validationType = validationType
            self.text = text
        }
    }

    enum Action: Equatable {
        case set(String)
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .set(let text):
            state.text = text
            state.valid = state.text.isValid(for: state.validationType)
        }
        return .none
    }
}

// MARK: - Store

extension TCATextFieldStore {
    static var transaction: Self {
        .init(
            initialState: .init(validationType: .customFloatingPoint(.zcashNumberFormatter), text: ""),
            reducer: TCATextFieldReducer()
        )
    }

    static var address: Self {
        .init(
            initialState: .init(validationType: .email, text: ""),
            reducer: TCATextFieldReducer()
        )
    }
}

// MARK: - Placeholders

extension TCATextFieldReducer.State {
    static let placeholder = TCATextFieldReducer.State(
        validationType: nil,
        text: ""
    )

    static let amount = TCATextFieldReducer.State(
        validationType: .floatingPoint,
        text: ""
    )
}
