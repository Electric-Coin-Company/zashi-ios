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
import SendConfirmation
@testable import secant_testnet

class SendSnapshotTests: XCTestCase {
    func testTransactionSendSnapshot() throws {
        var state = SendFlow.State.initial
        state.addMemoState = true

        let store = Store(
            initialState: state
        ) {
            SendFlow()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
                .dependency(\.exchangeRate, .noOp)
        }

        addAttachments(SendFlowView(store: store, tokenName: "ZEC"))
    }
    
    func testTransactionConfirmationScreen_withMemo() throws {
        let store = Store(
            initialState: .init(
                address: "",
                amount: .zero,
                feeRequired: .zero,
                message: "Testing memo",
                partialProposalErrorState: .initial,
                proposal: nil
            )
        ) {
            SendConfirmation()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.zcashSDKEnvironment, .testValue)
        }

        addAttachments(SendConfirmationView(store: store, tokenName: "ZEC"))
    }
    
    func testTransactionConfirmationScreen_memoMissing() throws {
        let store = Store(
            initialState: .init(
                address: "",
                amount: .zero,
                feeRequired: .zero,
                message: "",
                partialProposalErrorState: .initial,
                proposal: nil
            )
        ) {
            SendConfirmation()
                .dependency(\.derivationTool, .live())
                .dependency(\.mainQueue, DispatchQueue.main.eraseToAnyScheduler())
                .dependency(\.numberFormatter, .live())
                .dependency(\.walletStorage, .live())
                .dependency(\.sdkSynchronizer, .mock)
                .dependency(\.localAuthentication, .mockAuthenticationFailed)
                .dependency(\.zcashSDKEnvironment, .testValue)
        }

        addAttachments(SendConfirmationView(store: store, tokenName: "ZEC"))
    }
}
