//
//  TextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture
import Utils

typealias TCATextFieldStore = Store<TCATextFieldReducer.State, TCATextFieldReducer.Action>

struct TCATextFieldReducer: ReducerProtocol {
    struct State: Equatable {
        var validationType: String.ValidationType?
        var text = "".redacted
        var valid = false

        init(validationType: String.ValidationType?, text: RedactableString) {
            self.validationType = validationType
            self.text = text
        }
    }

    enum Action: Equatable {
        case set(RedactableString)
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .set(let text):
            state.text = text
            state.valid = state.text.data.isValid(for: state.validationType)
        }
        return .none
    }
}

// MARK: - Store

extension TCATextFieldStore {
    static var transaction: Self {
        .init(
            initialState: .init(validationType: .customFloatingPoint(.zcashNumberFormatter), text: "".redacted),
            reducer: TCATextFieldReducer()
        )
    }

    static var address: Self {
        .init(
            initialState: .init(validationType: .email, text: "".redacted),
            reducer: TCATextFieldReducer()
        )
    }
}

// MARK: - Placeholders

extension TCATextFieldReducer.State {
    static let placeholder = TCATextFieldReducer.State(
        validationType: nil,
        text: "".redacted
    )

    static let amount = TCATextFieldReducer.State(
        validationType: .floatingPoint,
        text: "".redacted
    )
}
