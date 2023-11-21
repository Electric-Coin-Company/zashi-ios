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
@testable import secant_testnet

class BalanceBreakdownSnapshotTests: XCTestCase {
    func testBalanceBreakdownSnapshot() throws {
        let store = Store(
            initialState: BalanceBreakdownReducer.State(
                autoShieldingThreshold: Zatoshi(1_000_000),
                changePending: .zero,
                isShieldingFunds: false,
                pendingTransactions: .zero,
                shieldedBalance: WalletBalance(verified: Zatoshi(123_000_000_000), total: Zatoshi(123_000_000_000)).redacted,
                synchronizerStatusSnapshot: .initial,
                transparentBalance: WalletBalance(verified: Zatoshi(850_000_000), total: Zatoshi(850_000_000)).redacted
            )
        ) {
            BalanceBreakdownReducer(networkType: .testnet)
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
        }
        
        addAttachments(BalanceBreakdownView(store: store, tokenName: "ZEC"))
    }
}
