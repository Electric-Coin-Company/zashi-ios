//
//  OnboardingFlowFeatureFlagTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 23.02.2023.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class OnboardingFlowFeatureFlagTests: XCTestCase {
    override func setUp() {
        super.setUp()

        UserDefaultsWalletConfigStorage().clearAll()
    }

    func testOnboardingFlowOffByDefault() throws {
        XCTAssertFalse(WalletConfig.default.isEnabled(.onboardingFlow))
    }

    func testOnboardingFlowOff_SkipEducation() {
        let initialState = OnboardingFlowReducer.State(
            walletConfig: .default,
            importWalletState: .placeholder
        )

        let store = TestStore(
            initialState: initialState,
            reducer: OnboardingFlowReducer()
        )

        store.send(.onAppear)

        store.receive(.skip) { state in
            state.index = initialState.steps.count - 1
            state.skippedAtindex = 0
        }
    }

    func testOnboardingFlowOn_StartEducation() {
        var defaultRawFlags = WalletConfig.default.flags
        defaultRawFlags[.onboardingFlow] = false
        let flags = WalletConfig(flags: defaultRawFlags)

        let initialState = OnboardingFlowReducer.State(
            walletConfig: flags,
            importWalletState: .placeholder
        )

        let store = TestStore(
            initialState: initialState,
            reducer: OnboardingFlowReducer()
        )

        store.send(.onAppear)

        store.receive(.skip) { state in
            state.index = initialState.steps.count - 1
            state.skippedAtindex = 0
        }
    }
}
