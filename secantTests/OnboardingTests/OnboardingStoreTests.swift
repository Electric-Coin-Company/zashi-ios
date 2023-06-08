//
//  OnboardingStoreTests.swift
//  OnboardingStoreTests
//
//  Created by Adam Stener on 10/10/21.
//

import XCTest
import ComposableArchitecture
import OnboardingFlow
@testable import secant_testnet

class OnboardingStoreTests: XCTestCase {
    func testIncrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
        )
        
        store.send(.next) { state in
            state.index += 1
            
            XCTAssertFalse(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[1])
            XCTAssertEqual(state.offset, -20.0)
            XCTAssertEqual(state.progress, 50)
        }
                
        store.send(.next) { state in
            state.index += 1
            
            XCTAssertFalse(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[2])
            XCTAssertEqual(state.offset, -40.0)
            XCTAssertEqual(state.progress, 75)
        }
        
        store.send(.next) { state in
            state.index += 1
            
            XCTAssertTrue(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[3])
            XCTAssertEqual(state.offset, -60.0)
            XCTAssertEqual(state.progress, 100)
        }
    }
    
    func testIncrementingPastTotalStepsDoesNothing() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder,
                index: 3
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
        )
        
        store.send(.next)
        store.send(.next)
    }
    
    func testDecrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder,
                index: 2
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
        )
        
        store.send(.back) { state in
            state.index -= 1
            
            XCTAssertFalse(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[1])
            XCTAssertEqual(state.offset, -20.0)
            XCTAssertEqual(state.progress, 50)
        }
                
        store.send(.back) { state in
            state.index -= 1
            
            XCTAssertFalse(state.isFinalStep)
            XCTAssertTrue(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[0])
            XCTAssertEqual(state.offset, 0.0)
            XCTAssertEqual(state.progress, 25)
        }
    }
    
    func testDecrementingPastFirstStepDoesNothing() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
        )
        
        store.send(.back)
        store.send(.back)
    }
    
    func testSkipOnboarding() {
        let initialIndex = 1

        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                walletConfig: .default,
                importWalletState: .placeholder,
                index: initialIndex
            ),
            reducer: OnboardingFlowReducer(saplingActivationHeight: 280_000)
        )
        
        store.send(.skip) { state in
            state.index = state.steps.count - 1
            state.skippedAtindex = initialIndex
            
            XCTAssertTrue(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[3])
            XCTAssertEqual(state.offset, -60.0)
            XCTAssertEqual(state.progress, 100)
        }
                
        store.send(.back) { state in
            state.skippedAtindex = nil
            state.index = initialIndex
            
            XCTAssertFalse(state.isFinalStep)
            XCTAssertFalse(state.isInitialStep)
            XCTAssertEqual(state.currentStep, state.steps[1])
            XCTAssertEqual(state.offset, -20.0)
            XCTAssertEqual(state.progress, 50)
        }
    }
}
