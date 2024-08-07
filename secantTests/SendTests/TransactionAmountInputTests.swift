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

@MainActor
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

    func testMaxValue() async throws {
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
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.setMax) { state in
            state.textFieldState.text = "0.00501301".redacted
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(501_301).redacted
        }
    }
    
    func testClearValue() async throws {
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
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        await store.send(.clearValue) { state in
            state.textFieldState.text = .empty
            XCTAssertEqual(0, state.amount.data, "AmountInput Tests: `testClearValue` expected \(0) but received \(state.amount.data)")
        }
    }
    
    func testZec_to_UsdConvertedAmount() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1,000".redacted
            state.currencySelectionState.currencyType = .usd
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
        }
    }
    
    func testBigZecAmount_to_UsdConvertedAmount() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "25,000,000".redacted
            state.currencySelectionState.currencyType = .usd
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(2_500_000_000_000).redacted
        }
    }
    
    func testUsd_to_ZecConvertedAmount() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.currencySelection(.swapCurrencyType)) { state in
            state.textFieldState.text = "1".redacted
            state.currencySelectionState.currencyType = .zec
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
        }
    }
    
    func testIfAmountIsMax() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        let value = "1 000".redacted
        
        await store.send(.textField(.set(value))) { state in
            state.textFieldState.text = value
            state.textFieldState.valid = true
            state.currencySelectionState.currencyType = .usd
            XCTAssertFalse(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be false but it's \(state.isMax)"
            )
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(100_000_000).redacted
            XCTAssertTrue(
                state.isMax,
                "AmountInput Tests: `testIfAmountIsMax` is expected to be true but it's \(state.isMax)"
            )
        }
    }
    
    func testMaxZecValue() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.setMax) { state in
            state.textFieldState.text = "2".redacted
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(200_000_000).redacted
        }
    }
    
    func testMaxUsdValue() async throws {
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
                        )
                )
        ) {
            TransactionAmountTextFieldReducer()
        }

        store.dependencies.numberFormatter.string = { self.usNumberFormatter.string(from: $0) }
        store.dependencies.numberFormatter.number = { self.usNumberFormatter.number(from: $0) }

        await store.send(.setMax) { state in
            state.textFieldState.text = "2,000".redacted
        }
        
        await store.receive(.updateAmount) { state in
            state.amount = Int64(200_000_000).redacted
        }
    }
}
