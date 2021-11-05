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
            initialState: OnboardingState(),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.next) {
            $0.index += 1
            
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
                
        store.send(.next) {
            $0.index += 1
            
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[2])
            XCTAssertEqual($0.offset, -40.0)
            XCTAssertEqual($0.progress, 75)
        }
        
        store.send(.next) {
            $0.index += 1
            
            XCTAssertTrue($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
    }
    
    func testIncrementingPastTotalStepsDoesNothing() {
        let store = TestStore(
            initialState: OnboardingState(index: 3),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.next) {
            XCTAssertTrue($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
                
        store.send(.next) {
            XCTAssertTrue($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
    }
    
    func testDecrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingState(index: 2),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.back) {
            $0.index -= 1
            
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
                
        store.send(.back) {
            $0.index -= 1
            
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertTrue($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[0])
            XCTAssertEqual($0.offset, 0.0)
            XCTAssertEqual($0.progress, 25)
        }
    }
    
    func testDecrementingPastFirstStepDoesNothing() {
        let store = TestStore(
            initialState: OnboardingState(),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.back) {
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertTrue($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[0])
            XCTAssertEqual($0.offset, 0.0)
            XCTAssertEqual($0.progress, 25)
        }
                
        store.send(.back) {
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertTrue($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[0])
            XCTAssertEqual($0.offset, 0.0)
            XCTAssertEqual($0.progress, 25)
        }
    }
    
    func testSkipOnboarding() {
        let initialIndex = 1

        let store = TestStore(
            initialState: OnboardingState(index: initialIndex),
            reducer: onboardingReducer,
            environment: ()
        )
        
        store.send(.skip) {
            $0.index = $0.steps.count - 1
            $0.skippedAtindex = initialIndex
            
            XCTAssertTrue($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
                
        store.send(.back) {
            $0.skippedAtindex = nil
            $0.index = initialIndex
            
            XCTAssertFalse($0.skipButtonDisabled)
            XCTAssertFalse($0.backButtonDisabled)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
    }
}
