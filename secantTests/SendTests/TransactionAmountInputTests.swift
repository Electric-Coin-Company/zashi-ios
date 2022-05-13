//
//  TransactionAmountTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

// TODO: these tests will be updated with the Zatoshi/Balance representative once done, issue #272 https://github.com/zcash/secant-ios-wallet/issues/272

// TODO: these test will be updated with the NumberFormater dependency to handle locale, issue #312 (https://github.com/zcash/secant-ios-wallet/issues/312)

class TransactionAmountTextFieldTests: XCTestCase {
    func testMaxValue() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.002"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_301
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.setMax) { state in
            state.textFieldState.text = "0.00501301"
            XCTAssertEqual(501_301, state.amount, "AmountInput Tests: `testMaxValue` expected \(501_301) but received \(state.amount)")
        }
    }
    
    func testClearValue() throws {
        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.002"
                        ),
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_301
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.clearValue) { state in
            state.textFieldState.text = ""
            XCTAssertEqual(0, state.amount, "AmountInput Tests: `testClearValue` expected \(0) but received \(state.amount)")
        }
    }
    
    func testZecUsdConvertedAmount() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testZecUsdConvertedAmount is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "1.0"
                        ),
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .zec
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1,000"
            state.currencySelectionState.currencyType = .usd
            XCTAssertEqual(
                100_000_000,
                state.amount,
                "AmountInput Tests: `testZecUsdConvertedAmount` expected \(100_000_000) but received \(state.amount)"
            )
        }
    }
    
    func testUsdZecConvertedAmount() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testUsdZecConvertedAmount is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "1 000"
                        ),
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1"
            state.currencySelectionState.currencyType = .zec
            XCTAssertEqual(
                100_000_000,
                state.amount,
                "AmountInput Tests: `testZecUsdConvertedAmount` expected \(100_000_000) but received \(state.amount)"
            )
        }
    }
    
    func testIfAmountIsMax() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testIfAmountIsMax is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    maxValue: 100_000_000,
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.textField(.set("1 000"))) { state in
            state.textFieldState.text = "1 000"
            state.textFieldState.valid = true
            state.currencySelectionState.currencyType = .usd
            XCTAssertTrue(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be true but it's \(state.isMax)"
            )
        }
    }
    
    func testMaxZecValue() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxZecValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .zec
                        ),
                    maxValue: 200_000_000,
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.setMax) { state in
            state.textFieldState.text = "2"
            XCTAssertEqual(
                200_000_000,
                state.maxCurrencyConvertedValue,
                "AmountInput Tests: `testMaxZecValue` expected \(200_000_000) but received \(state.maxCurrencyConvertedValue)"
            )
        }
    }
    
    func testMaxUsdValue() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxUsdValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    maxValue: 200_000_000,
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.setMax) { state in
            state.textFieldState.text = "2,000"
            XCTAssertEqual(
                200_000_000_000,
                state.maxCurrencyConvertedValue,
                "AmountInput Tests: `testMaxUsdValue` expected \(200_000_000_000) but received \(state.maxCurrencyConvertedValue)"
            )
        }
    }
}
