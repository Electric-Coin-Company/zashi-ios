//
//  TextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

typealias TCATextFieldReducer = Reducer<TCATextFieldState, TCATextFieldAction, TCATextFieldEnvironment>
typealias TCATextFieldStore = Store<TCATextFieldState, TCATextFieldAction>
typealias TCATextFieldViewStore = ViewStore<TCATextFieldState, TCATextFieldAction>

// MARK: - State

struct TCATextFieldState: Equatable {
    var validationType: String.ValidationType?
    var text: String
    var valid = false

    init(validationType: String.ValidationType?, text: String) {
        self.validationType = validationType
        self.text = text
    }
}

// MARK: - Action

enum TCATextFieldAction: Equatable {
    case set(String)
}

// MARK: - Environment

struct TCATextFieldEnvironment { }

// MARK: - Reducer

extension TCATextFieldReducer {
    static let `default` = TCATextFieldReducer { state, action, _ in
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
            reducer: .default,
            environment: .init()
        )
    }

    static var address: Self {
        .init(
            initialState: .init(validationType: .email, text: ""),
            reducer: .default,
            environment: .init()
        )
    }
}

// MARK: - Placeholders

extension TCATextFieldState {
    static let placeholder = TCATextFieldState(
        validationType: nil,
        text: ""
    )

    static let amount = TCATextFieldState(
        validationType: .floatingPoint,
        text: ""
    )
}
