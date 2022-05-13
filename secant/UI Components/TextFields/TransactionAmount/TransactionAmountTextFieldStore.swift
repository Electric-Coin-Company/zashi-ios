//
//  TransactionAmountTextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/5/22.
//

import ComposableArchitecture

typealias TransactionAmountTextFieldReducer = Reducer<
    TransactionAmountTextFieldState,
    TransactionAmountTextFieldAction,
    TransactionAmountTextFieldEnvironment
>

typealias TransactionAmountTextFieldStore = Store<TransactionAmountTextFieldState, TransactionAmountTextFieldAction>

struct TransactionAmountTextFieldState: Equatable {
    var textFieldState: TCATextFieldState
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

enum TransactionAmountTextFieldAction: Equatable {
    case clearValue
    case setMax
    case textField(TCATextFieldAction)
    case currencySelection(CurrencySelectionAction)
}

struct TransactionAmountTextFieldEnvironment: Equatable {}

extension TransactionAmountTextFieldReducer {
    static let `default` = TransactionAmountTextFieldReducer.combine(
        [
            textFieldReducer,
            currencySelectionReducer,
            maxOverride,
            currencyUpdate
        ]
    )

    static let maxOverride = TransactionAmountTextFieldReducer { state, action, _ in
        switch action {
        case .setMax:
            state.textFieldState.text = "\(state.maxCurrencyConvertedValue.asZecString())"

        case .clearValue:
            state.textFieldState.text = ""
            
        default: break
        }

        return .none
    }

    static let currencyUpdate = TransactionAmountTextFieldReducer { state, action, _ in
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

    private static let textFieldReducer: TransactionAmountTextFieldReducer = TCATextFieldReducer.default.pullback(
        state: \TransactionAmountTextFieldState.textFieldState,
        action: /TransactionAmountTextFieldAction.textField,
        environment: { _ in return .init() }
    )

    private static let currencySelectionReducer: TransactionAmountTextFieldReducer = CurrencySelectionReducer.default.pullback(
        state: \TransactionAmountTextFieldState.currencySelectionState,
        action: /TransactionAmountTextFieldAction.currencySelection,
        environment: { _ in return .init() }
    )
}

extension TransactionAmountTextFieldState {
    static let placeholder = TransactionAmountTextFieldState(
        textFieldState: .placeholder,
        currencySelectionState: CurrencySelectionState()
    )

    static let amount = TransactionAmountTextFieldState(
        textFieldState: .amount,
        currencySelectionState: CurrencySelectionState()
    )
}

extension TransactionAmountTextFieldStore {
    static let placeholder = TransactionAmountTextFieldStore(
        initialState: .placeholder,
        reducer: .default,
        environment: TransactionAmountTextFieldEnvironment()
    )
}
