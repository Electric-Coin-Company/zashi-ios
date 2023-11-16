//
//  PrivateDataConsentTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 01.11.2023.
//

import XCTest
import ComposableArchitecture
import PrivateDataConsent
@testable import secant_testnet

@MainActor
final class PrivateDataConsentTests: XCTestCase {
    func testURLsProperlyPrepared() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        let URL = URL(string: "https://electriccoin.co")!
        
        store.dependencies.databaseFiles.dataDbURLFor = { _ in URL }
        
        await store.send(.onAppear) { state in
            state.dataDbURL = [URL]
        }
        
        await store.finish()
    }
    
    func testExportRequestSet() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        await store.send(.exportRequested) { state in
            state.isExporting = true
        }
        
        await store.finish()
    }
    
    func testExportingDoneWhenFinished() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                isExporting: true,
                dataDbURL: []
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        await store.send(.shareFinished) { state in
            state.isExporting = false
        }
        
        await store.finish()
    }
}
