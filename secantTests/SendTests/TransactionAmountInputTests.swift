//
//  TransactionAmountTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

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
                    maxValue: 501_301,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "0.002"
                        )
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.setMax) { state in
            state.textFieldState.text = "0.00501301"
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 501_301
        }
    }
    
    func testClearValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldReducer.State(
                    currencySelectionState: CurrencySelectionReducer.State(),
                    maxValue: 501_301,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .floatingPoint,
                            text: "0.002"
                        )
                ),
            reducer: TransactionAmountTextFieldReducer()
        )

        store.send(.clearValue) { state in
            state.textFieldState.text = ""
            XCTAssertEqual(0, state.amount, "AmountInput Tests: `testClearValue` expected \(0) but received \(state.amount)")
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
                            text: "1.0"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1,000"
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 100_000_000
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
                            text: "25000"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "25,000,000"
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 2_500_000_000_000
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
                            text: "1 000"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1"
            state.currencySelectionState.currencyType = .zec
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 100_000_000
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
                    maxValue: 100_000_000,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.textField(.set("1 000"))) { state in
            state.textFieldState.text = "1 000"
            state.textFieldState.valid = true
            state.currencySelectionState.currencyType = .usd
            XCTAssertFalse(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be false but it's \(state.isMax)"
            )
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 100_000_000
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
                    maxValue: 200_000_000,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.setMax) { state in
            state.textFieldState.text = "2"
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 200_000_000
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
                    maxValue: 200_000_000,
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: .customFloatingPoint(usNumberFormatter),
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer()
        ) { dependencies in
            dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
            dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }
        }

        store.send(.setMax) { state in
            state.textFieldState.text = "2,000"
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 200_000_000
        }
    }
}
