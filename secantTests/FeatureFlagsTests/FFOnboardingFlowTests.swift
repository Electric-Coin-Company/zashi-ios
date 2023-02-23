//
//  FFOnboardingFlowTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 23.02.2023.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

class FFOnboardingFlowTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        UserDefaultsFeatureFlagsStorage().clearAll()
    }
    
    func testOnboardingFlowOffByDefault() throws {
        XCTAssertFalse(FeatureFlagsConfiguration.default.isEnabled(.onboardingFlow))
    }
    
    func testOnboardingFlowOff_SkipEducation() {
        let initialState = OnboardingFlowReducer.State(
            featureFlagsConfiguration: .default,
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
        var defaultRawFlags = FeatureFlagsConfiguration.default.flags
        defaultRawFlags[.onboardingFlow] = false
        let flags = FeatureFlagsConfiguration(flags: defaultRawFlags)
        
        let initialState = OnboardingFlowReducer.State(
            featureFlagsConfiguration: flags,
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
