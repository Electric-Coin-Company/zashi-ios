//
//  BalanceBreakdownSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 15.08.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import SwiftUI
import BalanceBreakdown
import PartialProposalError
@testable import secant_testnet

class BalanceBreakdownSnapshotTests: XCTestCase {
    func testBalanceBreakdownSnapshot() throws {
        let store = Store(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: false,
                partialProposalErrorState: .initial,
                pendingTransactions: .zero,
                syncProgressState: .initial,
                walletBalancesState: .initial
            )
        ) {
            BalanceBreakdownReducer()
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
                .dependency(\.restoreWalletStorage, .noOp)
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
        }
        
        addAttachments(BalanceBreakdownView(store: store, tokenName: "ZEC"))
    }
    
    func testBalanceBreakdownSnapshot_HintBox() throws {
        let store = Store(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: false,
                isHintBoxVisible: true,
                partialProposalErrorState: .initial,
                pendingTransactions: .zero,
                syncProgressState: .initial,
                walletBalancesState: .initial
            )
        ) {
            BalanceBreakdownReducer()
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
                .dependency(\.restoreWalletStorage, .noOp)
                .dependency(\.diskSpaceChecker, .mockEmptyDisk)
        }
        
        addAttachments(BalanceBreakdownView(store: store, tokenName: "ZEC"))
    }
}
