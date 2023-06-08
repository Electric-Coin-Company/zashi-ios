//
//  TransactionAmountTextFieldStore.swift
//  secant-testnet
//
//  Created by Adam Stener on 4/5/22.
//

import ComposableArchitecture
import ZcashLightClientKit
import Foundation
import Utils
import NumberFormatter

public typealias TransactionAmountTextFieldStore = Store<TransactionAmountTextFieldReducer.State, TransactionAmountTextFieldReducer.Action>

public struct TransactionAmountTextFieldReducer: ReducerProtocol {
    public struct State: Equatable {
        public var amount = RedactableInt64(0)
        public var currencySelectionState: CurrencySelectionReducer.State
        public var maxValue = RedactableInt64(0)
        public var textFieldState: TCATextFieldReducer.State
        // TODO: [#311] - Get the ZEC price from the SDK, https://github.com/zcash/secant-ios-wallet/issues/311
        public var zecPrice = Decimal(140.0)

        public var isMax: Bool {
            return amount == maxValue
        }
        
        public init(
            amount: RedactableInt64 = RedactableInt64(0),
            currencySelectionState: CurrencySelectionReducer.State,
            maxValue: RedactableInt64 = RedactableInt64(0),
            textFieldState: TCATextFieldReducer.State,
            zecPrice: Decimal = Decimal(140.0)
        ) {
            self.amount = amount
            self.currencySelectionState = currencySelectionState
            self.maxValue = maxValue
            self.textFieldState = textFieldState
            self.zecPrice = zecPrice
        }
    }

    public enum Action: Equatable {
        case clearValue
        case currencySelection(CurrencySelectionReducer.Action)
        case setMax
        case textField(TCATextFieldReducer.Action)
        case updateAmount
    }
    
    @Dependency(\.numberFormatter) var numberFormatter
    
    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.currencySelectionState, action: /Action.currencySelection) {
            CurrencySelectionReducer()
        }

        Scope(state: \.textFieldState, action: /Action.textField) {
            TCATextFieldReducer()
        }

        Reduce { state, action in
            switch action {
            case .setMax:
                let maxValueAsZec = Decimal(state.maxValue.data) / Decimal(Zatoshi.Constants.oneZecInZatoshi)
                let currencyType = state.currencySelectionState.currencyType
                let maxCurrencyConvertedValue: NSDecimalNumber = currencyType == .zec ?
                NSDecimalNumber(decimal: maxValueAsZec).roundedZec :
                NSDecimalNumber(decimal: maxValueAsZec * state.zecPrice).roundedZec
                
                let decimalString = numberFormatter.string(maxCurrencyConvertedValue) ?? ""
                
                state.textFieldState.text = "\(decimalString)".redacted
                return EffectTask(value: .updateAmount)

            case .clearValue:
                state.textFieldState.text = "".redacted
                return .none

            case .textField(.set):
                return EffectTask(value: .updateAmount)
                
            case .updateAmount:
                guard let number = numberFormatter.number(state.textFieldState.text.data) else {
                    state.amount = Int64(0).redacted
                    return .none
                }
                switch state.currencySelectionState.currencyType {
                case .zec:
                    state.amount = NSDecimalNumber(
                        decimal: number.decimalValue * Decimal(Zatoshi.Constants.oneZecInZatoshi)
                    ).roundedZec.int64Value.redacted
                case .usd:
                    let decimal = (number.decimalValue / state.zecPrice) * Decimal(Zatoshi.Constants.oneZecInZatoshi)
                    state.amount = NSDecimalNumber(decimal: decimal).roundedZec.int64Value.redacted
                }
                return .none
                
            case .currencySelection:
                guard let number = numberFormatter.number(state.textFieldState.text.data) else {
                    state.amount = Int64(0).redacted
                    return .none
                }
                
                let currencyType = state.currencySelectionState.currencyType
                
                let newValue = currencyType == .zec ?
                number.decimalValue / state.zecPrice :
                number.decimalValue * state.zecPrice
                
                let decimalString = numberFormatter.string(NSDecimalNumber(decimal: newValue)) ?? ""
                state.textFieldState.text = "\(decimalString)".redacted
                return EffectTask(value: .updateAmount)
            }
        }
    }
}

// MARK: - Placeholders

extension TransactionAmountTextFieldReducer.State {
    public static let placeholder = TransactionAmountTextFieldReducer.State(
        currencySelectionState: CurrencySelectionReducer.State(),
        textFieldState: .placeholder
    )

    public static let amount = TransactionAmountTextFieldReducer.State(
        currencySelectionState: CurrencySelectionReducer.State(),
        textFieldState: .amount
    )
}

extension TransactionAmountTextFieldStore {
    public static let placeholder = TransactionAmountTextFieldStore(
        initialState: .placeholder,
        reducer: TransactionAmountTextFieldReducer()
    )
}
