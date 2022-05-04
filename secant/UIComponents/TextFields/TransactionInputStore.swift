//
//  TransactionInputStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/5/22.
//

import ComposableArchitecture

typealias TransactionInputReducer = Reducer<
    TransactionInputState,
    TransactionInputAction,
    TransactionInputEnvironment
>
typealias TransactionReducerData = (inout TransactionInputState, TransactionInputAction) -> Void
typealias TransactionInputStore = Store<TransactionInputState, TransactionInputAction>

struct TransactionInputState: Equatable {
    var textFieldState: TextFieldState
    var currencySelectionState: CurrencySelectionState
    var maxValue: Int64 = 0
    
    var amount: Int64 {
        Int64((Double(textFieldState.text) ?? 0.0) * 100_000_000)
    }
}

enum TransactionInputAction: Equatable {
    case setMax(Int64)
    case textField(TextFieldAction)
    case currencySelection(CurrencySelectionAction)
}

struct TransactionInputEnvironment: Equatable {}

extension TransactionInputReducer {
    static let `default` = TransactionInputReducer.combine(
        [
            textFieldReducer,
            currencySelectionReducer,
            maxOverride,
            currencyUpdate
        ]
    )

    static let maxOverride = TransactionInputReducer { state, action, _ in
        switch action {
        case .setMax(let value):
            state.currencySelectionState.currencyType = .zec
            state.textFieldState.text = "\(value.asHumanReadableZecBalance())"

        default: break
        }

        return .none
    }

    static let currencyUpdate = TransactionInputReducer { state, action, _ in
        switch action {
        case .currencySelection:
            guard let currentDoubleValue = Double(state.textFieldState.text) else {
                return .none
            }

            let currencyType = state.currencySelectionState.currencyType

            // The 2100 is another hard coded value (🚀🌒) but the store could
            // have a dependency injected that would be responsible for
            // providing the current exchange rate.
            let newValue = currencyType == .zec ?
                currentDoubleValue / 2100 :
                currentDoubleValue * 2100
            state.textFieldState.text = "\(newValue)"

        default: break
        }

        return .none
    }

    private static let textFieldReducer: TransactionInputReducer = TextFieldReducer.default.pullback(
        state: \TransactionInputState.textFieldState,
        action: /TransactionInputAction.textField,
        environment: { _ in return .init() }
    )

    private static let currencySelectionReducer: TransactionInputReducer = CurrencySelectionReducer.default.pullback(
        state: \TransactionInputState.currencySelectionState,
        action: /TransactionInputAction.currencySelection,
        environment: { _ in return .init() }
    )
}

extension TransactionInputState {
    static let placeholer = TransactionInputState(
        textFieldState: .placeholder,
        currencySelectionState: CurrencySelectionState()
    )
}

extension TransactionInputStore {
    static let placeholder = TransactionInputStore(
        initialState: .placeholer,
        reducer: .default,
        environment: TransactionInputEnvironment()
    )
}
