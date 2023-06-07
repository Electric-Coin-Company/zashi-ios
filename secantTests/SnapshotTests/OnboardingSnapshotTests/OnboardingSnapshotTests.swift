//
//  OnboardingSnapshotTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 13.06.2022.
//

import XCTest
import ComposableArchitecture
import OnboardingFlow
@testable import secant_testnet

class OnboardingSnapshotTests: XCTestCase {
    func testOnboardingFlowSnapshot() throws {
        let store = OnboardingFlowStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
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
