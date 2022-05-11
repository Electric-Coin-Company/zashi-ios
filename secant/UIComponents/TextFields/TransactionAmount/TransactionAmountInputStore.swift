//
//  TransactionAmountInputStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/5/22.
//

import ComposableArchitecture

typealias TransactionAmountInputReducer = Reducer<
    TransactionAmountInputState,
    TransactionAmountInputAction,
    TransactionAmountInputEnvironment
>

typealias TransactionAmountInputStore = Store<TransactionAmountInputState, TransactionAmountInputAction>

struct TransactionAmountInputState: Equatable {
    var textFieldState: TextFieldState
    var currencySelectionState: CurrencySelectionState
    var maxValue: Int64 = 0
    // TODO: - Get the ZEC price from the SDK, issue 311, https://github.com/zcash/secant-ios-wallet/issues/311
    var zecPrice = 140.0
    
    var amount: Int64 {
        switch currencySelectionState.currencyType {
        case .zec:
            return (textFieldState.text.doubleValue ?? 0.0).asZec()
        case .usd:
            return ((textFieldState.text.doubleValue ?? 0.0) / zecPrice).asZec()
        }
    }

    var maxCurrencyConvertedValue: Int64 {
        switch currencySelectionState.currencyType {
        case .zec:
            return maxValue
        case .usd:
            return (maxValue.asHumanReadableZecBalance() * zecPrice).asZec()
        }
    }

    var isMax: Bool {
        return amount == maxValue
    }
}

enum TransactionAmountInputAction: Equatable {
    case clearValue
    case setMax
    case textField(TextFieldAction)
    case currencySelection(CurrencySelectionAction)
}

struct TransactionAmountInputEnvironment: Equatable {}

extension TransactionAmountInputReducer {
    static let `default` = TransactionAmountInputReducer.combine(
        [
            textFieldReducer,
            currencySelectionReducer,
            maxOverride,
            currencyUpdate
        ]
    )

    static let maxOverride = TransactionAmountInputReducer { state, action, _ in
        switch action {
        case .setMax:
            state.textFieldState.text = "\(state.maxCurrencyConvertedValue.asZecString())"

        case .clearValue:
            state.textFieldState.text = ""
            
        default: break
        }

        return .none
    }

    static let currencyUpdate = TransactionAmountInputReducer { state, action, _ in
        switch action {
        case .currencySelection:
            guard let currentDoubleValue = state.textFieldState.text.doubleValue else {
                return .none
            }

            let currencyType = state.currencySelectionState.currencyType

            let newValue = currencyType == .zec ?
            currentDoubleValue / state.zecPrice :
            currentDoubleValue * state.zecPrice
            state.textFieldState.text = "\(newValue.asZecString())"

        default: break
        }

        return .none
    }

    private static let textFieldReducer: TransactionAmountInputReducer = TextFieldReducer.default.pullback(
        state: \TransactionAmountInputState.textFieldState,
        action: /TransactionAmountInputAction.textField,
        environment: { _ in return .init() }
    )

    private static let currencySelectionReducer: TransactionAmountInputReducer = CurrencySelectionReducer.default.pullback(
        state: \TransactionAmountInputState.currencySelectionState,
        action: /TransactionAmountInputAction.currencySelection,
        environment: { _ in return .init() }
    )
}

extension TransactionAmountInputState {
    static let placeholder = TransactionAmountInputState(
        textFieldState: .placeholder,
        currencySelectionState: CurrencySelectionState()
    )

    static let amount = TransactionAmountInputState(
        textFieldState: .amount,
        currencySelectionState: CurrencySelectionState()
    )
}

extension TransactionAmountInputStore {
    static let placeholder = TransactionAmountInputStore(
        initialState: .placeholder,
        reducer: .default,
        environment: TransactionAmountInputEnvironment()
    )
}
