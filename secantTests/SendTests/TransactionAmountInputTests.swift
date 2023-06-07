//
//  TransactionAmountTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
import ComposableArchitecture
import UIComponents
@testable import secant_testnet

class TransactionAmountTextFieldTests: XCTestCase {
    let usNumberFormatter = NumberFormatter()
    
    override func setUp() {
        super.setUp()
        usNumberFormatter.maximumFractionDigits = 8
        usNumberFormatter.maximumIntegerDigits = 8
        usNumberFormatter.numberStyle = .decimal
        usNumberFormatter.usesGroupingSeparator = true
        usNumberFormatter.locale = Locale(identifier: "en_US")
    }

    func testMaxValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_301).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "0.002".redacted
                        )
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.setMax) { state in
            state.textFieldState.text = "0.00501301".redacted
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(501_301).redacted
        }
    }
    
    func testClearValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: Int64(501_301).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.002".redacted
                        )
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.send(.clearValue) { state in
            state.textFieldState.text = "".redacted
            XCTAssertEqual(0, state.amount.data, "AmountInput Tests: `testClearValue` expected \(0) but received \(state.amount.data)")
        }
    }
    
    func testZec_to_UsdConvertedAmount() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .zec
                        ),
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "1.0".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1,000".redacted
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
        }
    }
    
    func testBigZecAmount_to_UsdConvertedAmount() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .zec
                        ),
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "25000".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "25,000,000".redacted
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(2_500_000_000_000).redacted
        }
    }
    
    func testUsd_to_ZecConvertedAmount() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .usd
                        ),
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "1 000".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1".redacted
            state.currencySelectionState.currencyType = .zec
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
        }
    }
    
    func testIfAmountIsMax() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .usd
                        ),
                    maxValue: Int64(100_000_000).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        let value = "1 000".redacted
        store.send(.textField(.set(value))) { state in
            state.textFieldState.text = value
            state.textFieldState.valid = true
            state.currencySelectionState.currencyType = .usd
            XCTAssertFalse(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be false but it's \(state.isMax)"
            )
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
            XCTAssertTrue(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be true but it's \(state.isMax)"
            )
        }
    }
    
    func testMaxZecValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .zec
                        ),
                    maxValue: Int64(200_000_000).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.setMax) { state in
            state.textFieldState.text = "2".redacted
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(200_000_000).redacted
        }
    }
    
    func testMaxUsdValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState:
                        CurrencySelectionReducer.State(
                            currencyType: .usd
                        ),
                    maxValue: Int64(200_000_000).redacted,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5".redacted
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        store.send(.setMax) { state in
            state.textFieldState.text = "2,000".redacted
        }
        
        store.receive(.updateAmount) { state in
            state.amount = Int64(200_000_000).redacted
        }
    }
}
