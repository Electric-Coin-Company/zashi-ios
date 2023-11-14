//
//  TransactionSendingSnapshotTests.swift
//  secantTests
//
//  Created by Michal Fousek on 30.09.2022.
//

import XCTest
import ComposableArchitecture
import SwiftUI
import ZcashLightClientKit
import SendFlow
import UIComponents
@testable import secant_testnet

class SendSnapshotTests: XCTestCase {
    func testTransactionSendSnapshot() throws {
        var state = SendFlowReducer.State.initial
        state.addMemoState = true
        state.transactionAddressInputState = TransactionAddressTextFieldReducer.State(
            textFieldState: TCATextFieldReducer.State(
                validationType: nil,
                text: "ztestmockeddestinationaddress".redacted
            )
        )
        state.transactionAmountInputState = TransactionAmountTextFieldReducer.State(
            currencySelectionState: CurrencySelectionReducer.State(),
            textFieldState: TCATextFieldReducer.State(
                validationType: nil,
                text: "2.91".redacted
            )
        )

        let store = Store(
            initialState: state,
            reducer: {
                SendFlowReducer(networkType: .testnet)
                    .dependency(\.derivationTool, .live())
                    .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                    .dependency(\.numberFormatter, .live())
                    .dependency(\.walletStorage, .live())
                    .dependency(\.sdkSynchronizer, .mock)
            }
        )

        addAttachments(SendFlowView(store: store, tokenName: "ZEC"))
    }
}
