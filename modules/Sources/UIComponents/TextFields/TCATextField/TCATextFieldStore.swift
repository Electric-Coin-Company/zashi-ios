//
//  TextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/8/22.
//

import ComposableArchitecture
import Utils

public typealias TCATextFieldStore = Store<TCATextFieldReducer.State, TCATextFieldReducer.Action>

public struct TCATextFieldReducer: Reducer {
    public struct State: Equatable {
        public var validationType: String.ValidationType?
        public var text = "".redacted
        public var valid = false

        public init(validationType: String.ValidationType?, text: RedactableString) {
            self.validationType = validationType
            self.text = text
        }
    }

    public enum Action: Equatable {
        case set(RedactableString)
    }
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.Effect<Action> {
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
    public static var transaction: Self {
        .init(
            initialState: .init(validationType: .customFloatingPoint(.zcashNumberFormatter), text: "".redacted)
        ) {
            TCATextFieldReducer()
        }
    }

    public static var address: Self {
        .init(
            initialState: .init(validationType: .email, text: "".redacted)
        ) {
            TCATextFieldReducer()
        }
    }
}

// MARK: - Placeholders

extension TCATextFieldReducer.State {
    public static let initial = TCATextFieldReducer.State(
        validationType: nil,
        text: "".redacted
    )

    public static let amount = TCATextFieldReducer.State(
        validationType: .floatingPoint,
        text: "".redacted
    )
}
