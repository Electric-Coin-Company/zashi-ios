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

final class PrivateDataConsentTests: XCTestCase {
    func testURLsProperlyPrepared() throws {
        let store = TestStore(
            initialState: .initial
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        let URL = URL(string: "https://electriccoin.co")!
        
        store.dependencies.databaseFiles.dataDbURLFor = { _ in URL }
        
        store.send(.onAppear) { state in
            state.dataDbURL = [URL]
        }
    }
    
    func testExportRequestSet() throws {
        let store = TestStore(
            initialState: .initial
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.send(.exportRequested) { state in
            state.isExporting = true
        }
    }
    
    func testExportingDoneWhenFinished() throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                isExporting: true,
                dataDbURL: []
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.send(.shareFinished) { state in
            state.isExporting = false
        }
    }
}
