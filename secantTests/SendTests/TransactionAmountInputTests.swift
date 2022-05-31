//
//  TransactionAmountTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

// TODO: these test will be updated with the NumberFormater dependency to handle locale, issue #312 (https://github.com/zcash/secant-ios-wallet/issues/312)

class TransactionAmountTextFieldTests: XCTestCase {
    func testMaxValue() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_301,
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.002"
                        )
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

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
                TransactionAmountTextFieldState(
                    currencySelectionState: CurrencySelectionState(),
                    maxValue: 501_301,
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "0.002"
                        )
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.clearValue) { state in
            state.textFieldState.text = ""
            XCTAssertEqual(0, state.amount, "AmountInput Tests: `testClearValue` expected \(0) but received \(state.amount)")
        }
    }
    
    func testZec_to_UsdConvertedAmount() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testZec_to_UsdConvertedAmount is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .zec
                        ),
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "1.0"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1,000"
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 100_000_000
        }
    }
    
    func testBigZecAmount_to_UsdConvertedAmount() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testBigZecAmount_to_UsdConvertedAmount is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .zec
                        ),
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "25000"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "25,000,000"
            state.currencySelectionState.currencyType = .usd
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 2_500_000_000_000
        }
    }
    
    func testUsd_to_ZecConvertedAmount() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testUsd_to_ZecConvertedAmount is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "1 000"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1"
            state.currencySelectionState.currencyType = .zec
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 100_000_000
        }
    }
    
    func testIfAmountIsMax() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testIfAmountIsMax is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    maxValue: 100_000_000,
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

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
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxZecValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .zec
                        ),
                    maxValue: 200_000_000,
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.setMax) { state in
            state.textFieldState.text = "2"
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 200_000_000
        }
    }
    
    func testMaxUsdValue() throws {
        try XCTSkipUnless(Locale.current.regionCode == "US", "testMaxUsdValue is designed to test US locale only")

        let store = TestStore(
            initialState:
                TransactionAmountTextFieldState(
                    currencySelectionState:
                        CurrencySelectionState(
                            currencyType: .usd
                        ),
                    maxValue: 200_000_000,
                    textFieldState:
                        TCATextFieldState(
                            validationType: .floatingPoint,
                            text: "5"
                        ),
                    zecPrice: 1000.0
                ),
            reducer: TransactionAmountTextFieldReducer.default,
            environment: TransactionAmountTextFieldEnvironment()
        )

        store.send(.setMax) { state in
            state.textFieldState.text = "2,000"
        }
        
        store.receive(.updateAmount) { state in
            state.amount = 200_000_000
        }
    }
}
