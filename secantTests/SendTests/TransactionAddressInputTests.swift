//
//  TransactionAddressTextFieldTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class TransactionAddressTextFieldTests: XCTestCase {
    func testClearValue() throws {
        let store = TestStore(
            initialState:
                TransactionAddressTextFieldReducer.State(
                    textFieldState:
                        TCATextFieldReducer.State(
                            validationType: nil,
                            text: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
                        )
                ),
            reducer: TransactionAddressTextFieldReducer()
        )

        store.send(.clearAddress) { state in
            state.textFieldState.text = ""
        }
    }
}
