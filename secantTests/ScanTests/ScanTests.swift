//
//  ScanTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 17.05.2022.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture
import ZcashLightClientKit

class ScanTests: XCTestCase {
    func testOnAppearResetValues() throws {
        let store = TestStore(
            initialState:
                ScanReducer.State(
                    isTorchAvailable: true,
                    isTorchOn: true,
                    isValidValue: true,
                    scanStatus: .value("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")
                ),
            reducer: ScanReducer()
        )

        store.send(.onAppear) { state in
            state.isTorchAvailable = false
            state.isTorchOn = false
            state.isValidValue = false
            state.scanStatus = .unknown
        }
    }
    
    func testTorchOn() throws {
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
        )

        store.send(.torchPressed) { state in
            state.isTorchOn = true
        }
    }

    func testTorchOff() throws {
        let store = TestStore(
            initialState: ScanReducer.State(
                isTorchOn: true
            ),
            reducer: ScanReducer()
        )

        store.send(.torchPressed) { state in
            state.isTorchOn = false
        }
    }

    func testScannedInvalidValue() throws {
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
        )

        store.send(.scan("test")) { state in
            state.scanStatus = .value("test")
            state.isValidValue = false
        }
    }

    func testScannedValidAddress() throws {
        let testScheduler = DispatchQueue.test
        
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
                .dependency(\.mainQueue, testScheduler.eraseToAnyScheduler())
        )

        store.send(.scan("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")) { state in
            state.scanStatus = .value("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po")
            state.isValidValue = true
        }
        
        testScheduler.advance(by: 1.01)
        
        store.receive(.found("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po"))
    }

    func testScanFailed() throws {
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
        )

        store.send(.scanFailed) { state in
            state.scanStatus = .failed
        }
    }
}
