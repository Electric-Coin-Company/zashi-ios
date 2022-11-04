//
//  BalanceBreakdownTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 15.08.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class BalanceBreakdownTests: XCTestCase {
    func testOnAppear() throws {
        // setup the store and environment to be fully mocked
        let testScheduler = DispatchQueue.test

        let store = TestStore(
            initialState: .placeholder,
            reducer: BalanceBreakdownReducer()
                .dependency(\.mainQueue, testScheduler.eraseToAnyScheduler())
        )
        
        store.send(.onAppear)
        
        testScheduler.advance(by: 0.1)
        
        // expected side effects as a result of .onAppear registration
        store.receive(.synchronizerStateChanged(.unknown))
        store.receive(.updateSynchronizerStatus)
        store.receive(.updateLatestBlock)

        // long-living (cancelable) effects need to be properly canceled.
        // the .onDisappear action cancles the observer of the synchronizer status change.
        store.send(.onDisappear)
    }
}
