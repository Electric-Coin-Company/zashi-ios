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
                shieldedBalance: Zatoshi(123_000_000_000),
                syncProgressState: .initial,
                totalBalance: Zatoshi(123_000_000_000),
                transparentBalance: Zatoshi(850_000_000)
            )
        ) {
            BalanceBreakdownReducer()
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
                .dependency(\.restoreWalletStorage, .noOp)
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
                pendingTransactions: .zero,
                shieldedBalance: Zatoshi(123_000_000_000),
                syncProgressState: .initial,
                totalBalance: Zatoshi(123_000_000_000),
                transparentBalance: Zatoshi(850_000_000)
            )
        ) {
            BalanceBreakdownReducer()
                .dependency(\.sdkSynchronizer, .noOp)
                .dependency(\.mainQueue, .immediate)
                .dependency(\.restoreWalletStorage, .noOp)
        }
        
        addAttachments(BalanceBreakdownView(store: store, tokenName: "ZEC"))
    }
}
