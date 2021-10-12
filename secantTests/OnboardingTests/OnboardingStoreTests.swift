//
//  OnboardingStoreTests.swift
//  OnboardingStoreTests
//
//  Created by Adam Stener on 10/10/21.
//

import XCTest
import ComposableArchitecture
@testable import secant_testnet

class OnboardingStoreTests: XCTestCase {
    func testIncrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingState(steps: OnboardingState.steps),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.nextPressed) {
            $0.index += 1
            $0.offset -= 20.0
            
            XCTAssertFalse($0.nextButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, OnboardingState.steps[1])
            XCTAssertEqual($0.progress, 66)
        }
                
        store.send(.nextPressed) {
            $0.index += 1
            $0.offset -= 20.0
            
            XCTAssertTrue($0.nextButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, OnboardingState.steps[2])
            XCTAssertEqual($0.progress, 100)
        }
    }
    
    func testDecrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingState(
                steps: OnboardingState.steps,
                index: 2,
                offset: .zero - 20.0 - 20.0
            ),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.backPressed) {
            $0.index -= 1
            $0.offset += 20.0
            
            XCTAssertFalse($0.nextButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, OnboardingState.steps[1])
            XCTAssertEqual($0.progress, 66)
        }
                
        store.send(.backPressed) {
            $0.index -= 1
            $0.offset += 20.0
            
            XCTAssertFalse($0.nextButtonDisabled)
            XCTAssertTrue($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, OnboardingState.steps[0])
            XCTAssertEqual($0.progress, 33)
        }
    }
}
