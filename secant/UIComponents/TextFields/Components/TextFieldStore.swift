//
//  TextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture

typealias TextFieldReducer = Reducer<TextFieldState, TextFieldAction, TextFieldEnvironment>
typealias TextFieldStore = Store<TextFieldState, TextFieldAction>

struct TextFieldState: Equatable {
    var validationType: String.ValidationType?
    var text: String
    var valid = false

    init(validationType: String.ValidationType?, text: String) {
        self.validationType = validationType
        self.text = text
    }
}

enum TextFieldAction: Equatable {
//    case apply((String) -> String)
    case set(String)
}

struct TextFieldEnvironment: Equatable { }

extension TextFieldReducer {
    static let `default` = TextFieldReducer { state, action, _ in
        switch action {
            //        case .apply(let action):
            //            state.text = action(state.text)
            //            state.valid = state.text.isValid(for: state.validationType)
        case .set(let text):
            state.text = text
            state.valid = state.text.isValid(for: state.validationType)
        }
        return .none
    }
}

extension TextFieldStore {
    static var transaction: Self {
        .init(
            initialState: .init(validationType: .floatingPoint, text: ""),
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

extension TextFieldState {
    static let placeholder = TextFieldState(
        validationType: nil,
        text: ""
    )
}
