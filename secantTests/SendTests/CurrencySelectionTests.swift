//
//  CurrencySelectionTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 09.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class CurrencySelectionTests: XCTestCase {
    func testCurrencySwapUsdToZec() throws {
        let store = TestStore(
            initialState: CurrencySelectionState(currencyType: .usd),
            reducer: CurrencySelectionReducer.default,
            environment: CurrencySelectionEnvironment()
        )

        store.send(.swapCurrencyType) { state in
            state.currencyType = .zec
        }
    }

    func testCurrencySwapZecToUsd() throws {
        let store = TestStore(
            initialState: CurrencySelectionState(currencyType: .zec),
            reducer: CurrencySelectionReducer.default,
            environment: CurrencySelectionEnvironment()
        )

        store.send(.swapCurrencyType) { state in
            state.currencyType = .usd
        }
    }
}
