//
//  TransactionSendingTests.swift
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
        let testEnvironment = SendFlowEnvironment(
            derivationTool: .live(derivationTool: DerivationTool(networkType: .testnet)),
            mnemonic: .mock,
            numberFormatter: .live(),
            SDKSynchronizer: MockWrappedSDKSynchronizer(),
            scheduler: DispatchQueue.main.eraseToAnyScheduler(),
            walletStorage: .live(),
            zcashSDKEnvironment: .testnet
        )

        var state = SendFlowState.placeholder
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
            reducer: SendFlowReducer.default,
            environment: testEnvironment
        )

        ViewStore(store).send(.onAppear)
        addAttachments(TransactionSendingView(viewStore: ViewStore(store)))
    }
}
