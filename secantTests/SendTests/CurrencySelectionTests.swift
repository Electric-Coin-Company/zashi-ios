//
//  CurrencySelectionTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 09.05.2022.
//

import XCTest
import ComposableArchitecture
import UIComponents
@testable import secant_testnet

@MainActor
class CurrencySelectionTests: XCTestCase {
    func testCurrencySwapUsdToZec() async throws {
        let store = TestStore(
            initialState: CurrencySelectionReducer.State(currencyType: .usd)
        ) {
            CurrencySelectionReducer()
        }

        await store.send(.swapCurrencyType) { state in
            state.currencyType = .zec
        }
    }

    func testCurrencySwapZecToUsd() async throws {
        let store = TestStore(
            initialState: CurrencySelectionReducer.State(currencyType: .zec)
        ) {
            CurrencySelectionReducer()
        }

        await store.send(.swapCurrencyType) { state in
            state.currencyType = .usd
        }
    }
}
