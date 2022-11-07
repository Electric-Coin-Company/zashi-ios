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
            initialState: OnboardingFlowReducer.State(
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        store.send(.next) {
            $0.index += 1
            
            XCTAssertFalse($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
                
        store.send(.next) {
            $0.index += 1
            
            XCTAssertFalse($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[2])
            XCTAssertEqual($0.offset, -40.0)
            XCTAssertEqual($0.progress, 75)
        }
        
        store.send(.next) {
            $0.index += 1
            
            XCTAssertTrue($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
    }
    
    func testIncrementingPastTotalStepsDoesNothing() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                index: 3,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        store.send(.next)
        store.send(.next)
    }
    
    func testDecrementingOnboarding() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                index: 2,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        store.send(.back) {
            $0.index -= 1
            
            XCTAssertFalse($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
                
        store.send(.back) {
            $0.index -= 1
            
            XCTAssertFalse($0.isFinalStep)
            XCTAssertTrue($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[0])
            XCTAssertEqual($0.offset, 0.0)
            XCTAssertEqual($0.progress, 25)
        }
    }
    
    func testDecrementingPastFirstStepDoesNothing() {
        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        store.send(.back)
        store.send(.back)
    }
    
    func testSkipOnboarding() {
        let initialIndex = 1

        let store = TestStore(
            initialState: OnboardingFlowReducer.State(
                index: initialIndex,
                importWalletState: .placeholder
            ),
            reducer: OnboardingFlowReducer()
        )
        
        store.send(.skip) {
            $0.index = $0.steps.count - 1
            $0.skippedAtindex = initialIndex
            
            XCTAssertTrue($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[3])
            XCTAssertEqual($0.offset, -60.0)
            XCTAssertEqual($0.progress, 100)
        }
                
        store.send(.back) {
            $0.skippedAtindex = nil
            $0.index = initialIndex
            
            XCTAssertFalse($0.isFinalStep)
            XCTAssertFalse($0.isInitialStep)
            XCTAssertEqual($0.currentStep, $0.steps[1])
            XCTAssertEqual($0.offset, -20.0)
            XCTAssertEqual($0.progress, 50)
        }
    }
}
