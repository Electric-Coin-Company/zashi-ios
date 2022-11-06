//
//  TransactionAmountTextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/5/22.
//

import ComposableArchitecture
import ZcashLightClientKit
import Foundation

typealias TransactionAmountTextFieldReducer = Reducer<
    TransactionAmountTextFieldState,
    TransactionAmountTextFieldAction,
    TransactionAmountTextFieldEnvironment
>

typealias TransactionAmountTextFieldStore = Store<TransactionAmountTextFieldState, TransactionAmountTextFieldAction>

typealias AnyTCATextFieldReducerAmount = AnyReducer<TCATextFieldReducer.State, TCATextFieldReducer.Action, TransactionAmountTextFieldEnvironment>
typealias AnyCurrencySelectionReducer = AnyReducer<CurrencySelectionReducer.State, CurrencySelectionReducer.Action, TransactionAmountTextFieldEnvironment>

struct TransactionAmountTextFieldState: Equatable {
    var amount: Int64 = 0
    var currencySelectionState: CurrencySelectionReducer.State
    var maxValue: Int64 = 0
    var textFieldState: TCATextFieldReducer.State
    // TODO [#311]: - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
    var zecPrice = Decimal(140.0)

    var isMax: Bool {
        return amount == maxValue
    }
}

enum TransactionAmountTextFieldAction: Equatable {
    case clearValue
    case currencySelection(CurrencySelectionReducer.Action)
    case setMax
    case textField(TCATextFieldReducer.Action)
    case updateAmount
}

struct TransactionAmountTextFieldEnvironment {
    let numberFormatter: WrappedNumberFormatter
}

extension TransactionAmountTextFieldReducer {
    static let `default` = TransactionAmountTextFieldReducer.combine(
        [
            textFieldReducer,
            currencySelectionReducer,
            amountTextFieldReducer
        ]
    )

    static let amountTextFieldReducer = TransactionAmountTextFieldReducer { state, action, environment in
        switch action {
        case .setMax:
            let maxValueAsZec = Decimal(state.maxValue) / Decimal(Zatoshi.Constants.oneZecInZatoshi)
            let currencyType = state.currencySelectionState.currencyType
            let maxCurrencyConvertedValue: NSDecimalNumber = currencyType == .zec ?
            NSDecimalNumber(decimal: maxValueAsZec).roundedZec :
            NSDecimalNumber(decimal: maxValueAsZec * state.zecPrice).roundedZec
            
            let decimalString = environment.numberFormatter.string(maxCurrencyConvertedValue) ?? ""
            
            state.textFieldState.text = "\(decimalString)"
            return Effect(value: .updateAmount)

        case .clearValue:
            state.textFieldState.text = ""
            return .none

        case .textField(.set(let amount)):
            return Effect(value: .updateAmount)
            
        case .updateAmount:
            guard var number = environment.numberFormatter.number(state.textFieldState.text) else {
                state.amount = 0
                return .none
            }
            switch state.currencySelectionState.currencyType {
            case .zec:
                state.amount = NSDecimalNumber(decimal: number.decimalValue * Decimal(Zatoshi.Constants.oneZecInZatoshi)).roundedZec.int64Value
            case .usd:
                let decimal = (number.decimalValue / state.zecPrice) * Decimal(Zatoshi.Constants.oneZecInZatoshi)
                state.amount = NSDecimalNumber(decimal: decimal).roundedZec.int64Value
            }
            return .none
            
        case .currencySelection:
            guard let number = environment.numberFormatter.number(state.textFieldState.text) else {
                state.amount = 0
                return .none
            }
            
            let currencyType = state.currencySelectionState.currencyType
            
            let newValue = currencyType == .zec ?
            number.decimalValue / state.zecPrice :
            number.decimalValue * state.zecPrice
            
            let decimalString = environment.numberFormatter.string(NSDecimalNumber(decimal: newValue)) ?? ""
            state.textFieldState.text = "\(decimalString)"
            return Effect(value: .updateAmount)
        }
    }

    private static let textFieldReducer: TransactionAmountTextFieldReducer = AnyTCATextFieldReducerAmount { _ in
        TCATextFieldReducer()
    }
    .pullback(
        state: \TransactionAmountTextFieldState.textFieldState,
        action: /TransactionAmountTextFieldAction.textField,
        environment: { $0 }
    )
    
    private static let currencySelectionReducer: TransactionAmountTextFieldReducer = AnyCurrencySelectionReducer { _ in
        CurrencySelectionReducer()
    }
    .pullback(
        state: \TransactionAmountTextFieldState.currencySelectionState,
        action: /TransactionAmountTextFieldAction.currencySelection,
        environment: { $0 }
    )
}

extension TransactionAmountTextFieldState {
    static let placeholder = TransactionAmountTextFieldState(
        currencySelectionState: CurrencySelectionReducer.State(),
        textFieldState: .placeholder
    )

    static let amount = TransactionAmountTextFieldState(
        currencySelectionState: CurrencySelectionReducer.State(),
        textFieldState: .amount
    )
}

extension TransactionAmountTextFieldStore {
    static let placeholder = TransactionAmountTextFieldStore(
        initialState: .placeholder,
        reducer: .default,
        environment:
            TransactionAmountTextFieldEnvironment(
                numberFormatter: .live()
            )
    )
}
