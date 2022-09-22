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

struct TransactionAmountTextFieldState: Equatable {
    var amount: Int64 = 0
    var currencySelectionState: CurrencySelectionState
    var maxValue: Int64 = 0
    var textFieldState: TCATextFieldState
    // TODO [#311]: - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
    var zecPrice = Decimal(140.0)

    var isMax: Bool {
        return amount == maxValue
    }
}

enum TransactionAmountTextFieldAction: Equatable {
    case clearValue
    case currencySelection(CurrencySelectionAction)
    case setMax
    case textField(TCATextFieldAction)
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
        currencySelectionState: CurrencySelectionState(),
        textFieldState: .placeholder
    )

    static let amount = TransactionAmountTextFieldState(
        currencySelectionState: CurrencySelectionState(),
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
