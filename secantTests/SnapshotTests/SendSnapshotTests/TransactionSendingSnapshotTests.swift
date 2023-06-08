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

class TransactionSendingTests: XCTestCase {
    func testTransactionSendingSnapshot() throws {
        var state = SendFlowReducer.State.placeholder
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
            reducer: SendFlowReducer(networkType: .testnet)
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
        )

        ViewStore(store).send(.onAppear)
        addAttachments(TransactionSendingView(viewStore: ViewStore(store), tokenName: "ZEC"))
    }
}
