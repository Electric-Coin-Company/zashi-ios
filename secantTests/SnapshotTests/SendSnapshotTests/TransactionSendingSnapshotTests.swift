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
import Utils
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
            initialState: state
        ) {
            SendFlowReducer()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
        }

        addAttachments(SendFlowView(store: store, tokenName: "ZEC"))
    }
    
    func testTransactionConfirmationScreen_withMemo() throws {
        let store = Store(
            initialState: .init(
                addMemoState: true,
                destination: nil,
                memoState: MessageEditorReducer.State(
                    charLimit: 512,
                    text: "This is some message I want to see in the preview and long enough to have at least two lines".redacted
                ),
                partialProposalErrorState: .initial,
                scanState: .initial,
                spendableBalance: Zatoshi(4412323012_345),
                transactionAddressInputState:
                    TransactionAddressTextFieldReducer.State(
                        textFieldState:
                            TCATextFieldReducer.State(
                                validationType: nil,
                                text:
                                    // swiftlint:disable line_length
                                    "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h".redacted
                            )
                    ),
                transactionAmountInputState: TransactionAmountTextFieldReducer.State(
                    amount: RedactableInt64(9153234),
                    currencySelectionState: CurrencySelectionReducer.State(),
                    textFieldState: TCATextFieldReducer.State(
                        validationType: nil,
                        text: "0.9153234".redacted
                    )
                )
            )
        ) {
            SendFlowReducer()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
        }

        addAttachments(SendFlowConfirmationView(store: store, tokenName: "ZEC"))
    }
    
    func testTransactionConfirmationScreen_memoMissing() throws {
        let store = Store(
            initialState: .init(
                addMemoState: true,
                destination: nil,
                memoState: MessageEditorReducer.State(),
                partialProposalErrorState: .initial,
                scanState: .initial,
                spendableBalance: Zatoshi(4412323012_345),
                transactionAddressInputState:
                    TransactionAddressTextFieldReducer.State(
                        textFieldState:
                            TCATextFieldReducer.State(
                                validationType: nil,
                                text:
                                    // swiftlint:disable line_length
                                    "utest1zkkkjfxkamagznjr6ayemffj2d2gacdwpzcyw669pvg06xevzqslpmm27zjsctlkstl2vsw62xrjktmzqcu4yu9zdhdxqz3kafa4j2q85y6mv74rzjcgjg8c0ytrg7dwyzwtgnuc76h".redacted
                            )
                    ),
                transactionAmountInputState: TransactionAmountTextFieldReducer.State(
                    amount: RedactableInt64(9153234),
                    currencySelectionState: CurrencySelectionReducer.State(),
                    textFieldState: TCATextFieldReducer.State(
                        validationType: nil,
                        text: "0.9153234".redacted
                    )
                )
            )
        ) {
            SendFlowReducer()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
        }

        addAttachments(SendFlowConfirmationView(store: store, tokenName: "ZEC"))
    }
}
