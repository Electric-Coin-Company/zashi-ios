//
//  TransactionSendingSnapshotTests.swift
//  secantTests
//
//  Created by Michal Fousek on 30.09.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit

class TransactionSendingTests: XCTestCase {
    func testTransactionSendingSnapshot() throws {
        var state = SendFlowReducer.State.placeholder
        state.addMemoState = true
        state.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState: TCATextFieldReducer.State(
                validationType: nil,
                text: "ztestmockeddestinationaddress"
            )
        )
        state.transactionAmountInputState = TransactionAmountTextFieldReducer.State(
            currencySelectionState: CurrencySelectionReducer.State(),
            textFieldState: TCATextFieldReducer.State(
                validationType: nil,
                text: "2.91"
            )
        )

        let store = Store(
            initialState: state,
            reducer: SendFlowReducer()
                .dependency(\.derivationTool, .live(networkType: .testnet))
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
        )

        ViewStore(store).send(.onAppear)
        addAttachments(TransactionSendingView(viewStore: ViewStore(store)))
    }
}
