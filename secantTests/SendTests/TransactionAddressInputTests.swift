//
//  TransactionAddressInputTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 06.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class TransactionAddressInputTests: XCTestCase {
    func testClearValue() throws {
        let store = TestStore(
            initialState:
                TransactionAddressInputState(
                    textFieldState:
                        TextFieldState(
                            validationType: nil,
                            text: "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"
                        )
                ),
            reducer: TransactionAddressInputReducer.default,
            environment:
                TransactionAddressInputEnvironment(
                    wrappedDerivationTool: .live()
                )
        )

        store.send(.clearAddress) { state in
            state.textFieldState.text = ""
        }
    }
}
