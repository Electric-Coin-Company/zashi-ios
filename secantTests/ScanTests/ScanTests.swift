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
                    scanStatus: .value("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted)
                ),
            reducer: ScanReducer()
        ) {
            $0.captureDevice = .noOp
        }
        
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
        ) {
            $0.captureDevice = .noOp
        }

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
        ) {
            $0.captureDevice = .noOp
        }

        store.send(.torchPressed) { state in
            state.isTorchOn = false
        }
    }

    func testScannedInvalidValue() throws {
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
        ) {
            $0.uriParser.isValidURI = { _ in false }
        }
        
        let value = "test".redacted
        store.send(.scan(value)) { state in
            state.scanStatus = .value(value)
            state.isValidValue = false
        }
    }

    func testScannedValidAddress() throws {
        let testScheduler = DispatchQueue.test
        
        let store = TestStore(
            initialState: ScanReducer.State(),
            reducer: ScanReducer()
        ) { dependencies in
            dependencies.mainQueue = testScheduler.eraseToAnyScheduler()
            dependencies.uriParser.isValidURI = { _ in true }
        }

        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        store.send(.scan(address)) { state in
            state.scanStatus = .value(address)
            state.isValidValue = true
        }
        
        testScheduler.advance(by: 1.01)
        
        store.receive(.found(address))
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
