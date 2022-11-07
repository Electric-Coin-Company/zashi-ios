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
            initialState: CurrencySelectionReducer.State(currencyType: .usd),
            reducer: CurrencySelectionReducer()
        )

        store.send(.swapCurrencyType) { state in
            state.currencyType = .zec
        }
    }

    func testCurrencySwapZecToUsd() throws {
        let store = TestStore(
            initialState: CurrencySelectionReducer.State(currencyType: .zec),
            reducer: CurrencySelectionReducer()
        )

        store.send(.swapCurrencyType) { state in
            state.currencyType = .usd
        }
    }
}
