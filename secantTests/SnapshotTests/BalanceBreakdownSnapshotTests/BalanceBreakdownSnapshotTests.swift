//
//  BalanceBreakdownSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 15.08.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit
import SwiftUI

class BalanceBreakdownSnapshotTests: XCTestCase {
    func testBalanceBreakdownSnapshot() throws {
        let store = Store(
            initialState: BalanceBreakdownState(
                autoShieldingTreshold: Zatoshi(1_000_000),
                latestBlock: "unknown",
                shieldedBalance: WalletBalance(verified: Zatoshi(123_000_000_000), total: Zatoshi(123_000_000_000)),
                transparentBalance: WalletBalance(verified: Zatoshi(850_000_000), total: Zatoshi(850_000_000))
            ),
            reducer: BalanceBreakdownReducer.default,
            environment: .mock
        )
        
        addAttachments(BalanceBreakdown(store: store))
    }
}
