//
//  ScanTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 17.05.2022.
//

import XCTest
import ComposableArchitecture
import ZcashLightClientKit
import Scan
@testable import secant_testnet

@MainActor
class ScanTests: XCTestCase {
    func testOnAppearResetValues() async throws {
        let store = TestStore(
            initialState:
                ScanReducer.State(
                    isTorchAvailable: true,
                    isTorchOn: true,
                    scanStatus: .value("t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted)
                )
        ) {
            ScanReducer(networkType: .testnet)
        }

        store.dependencies.captureDevice = .noOp
        
        await store.send(.onAppear) { state in
            state.isTorchAvailable = false
            state.isTorchOn = false
            state.scanStatus = .unknown
        }
        
        await store.finish()
    }
    
    func testTorchOn() async throws {
        let store = TestStore(
            initialState: ScanReducer.State()
        ) {
            ScanReducer(networkType: .testnet)
        }

        store.dependencies.captureDevice = .noOp

        await store.send(.torchPressed) { state in
            state.isTorchOn = true
        }
        
        await store.finish()
    }

    func testTorchOff() async throws {
        let store = TestStore(
            initialState: ScanReducer.State(
                isTorchOn: true
            )
        ) {
            ScanReducer(networkType: .testnet)
        }

        store.dependencies.captureDevice = .noOp

        await store.send(.torchPressed) { state in
            state.isTorchOn = false
        }
        
        await store.finish()
    }

    func testScannedInvalidValue() async throws {
        let store = TestStore(
            initialState: ScanReducer.State()
        ) {
            ScanReducer(networkType: .testnet)
        }

        store.dependencies.uriParser.isValidURI = { _, _ in false }
        
        let value = "test".redacted
        
        await store.send(.scan(value)) { state in
            state.scanStatus = .failed
        }
        
        await store.finish()
    }

    @MainActor func testScannedValidAddress() async throws {
        let store = TestStore(
            initialState: ScanReducer.State()
        ) {
            ScanReducer(networkType: .testnet)
        }
        
        store.dependencies.mainQueue = .immediate
        store.dependencies.uriParser.isValidURI = { _, _ in true }

        let address = "t1gXqfSSQt6WfpwyuCU3Wi7sSVZ66DYQ3Po".redacted
        
        await store.send(.scan(address)) { state in
            state.scanStatus = .value(address)
        }
        
        await store.receive(.found(address))
        
        await store.finish()
    }

    func testScanFailed() async throws {
        let store = TestStore(
            initialState: ScanReducer.State()
        ) {
            ScanReducer(networkType: .testnet)
        }

        await store.send(.scanFailed) { state in
            state.scanStatus = .failed
        }
        
        await store.finish()
    }
}
