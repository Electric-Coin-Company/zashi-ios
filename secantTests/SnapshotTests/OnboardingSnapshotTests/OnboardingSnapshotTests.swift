//
//  OnboardingSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class OnboardingSnapshotTests: XCTestCase {
    func testOnboardingFlowSnapshot() throws {
        let store = OnboardingFlowStore(
            initialState: OnboardingFlowReducer.State(importWalletState: .placeholder),
            reducer: OnboardingFlowReducer()
        )
        let viewStore = ViewStore(store)

        // step 1
        addAttachments(
            name: "\(#function)_info1",
            OnboardingScreen(store: store)
        )
        
        // step 2
        viewStore.send(.next)
        addAttachments(
            name: "\(#function)_info2",
            OnboardingScreen(store: store)
        )

        // step 3
        viewStore.send(.next)
        addAttachments(
            name: "\(#function)_info3",
            OnboardingScreen(store: store)
        )

        // step 4
        viewStore.send(.next)
        addAttachments(
            name: "\(#function)_info4",
            OnboardingScreen(store: store)
        )
    }
}
