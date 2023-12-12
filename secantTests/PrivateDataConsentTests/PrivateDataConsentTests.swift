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
            initialState: PrivateDataConsentReducer.State(
                isExporting: false,
                dataDbURL: [],
                exportOnlyLogs: true,
                exportLogsState: .initial
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.dependencies.logsHandler = .noOp
        
        await store.send(.exportRequested) { state in
            state.exportOnlyLogs = false
        }
        
        await store.receive(.exportLogs(.start)) { state in
            state.exportLogsState.exportLogsDisabled = true
        }
        
        await store.receive(.exportLogs(.finished(nil))) { state in
            state.exportLogsState.exportLogsDisabled = false
            state.exportLogsState.isSharingLogs = true
            state.isExporting = true
        }

        await store.finish()
    }
    
    func testExportLogsRequestSet() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                isExporting: false,
                dataDbURL: [],
                exportOnlyLogs: false,
                exportLogsState: .initial
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.dependencies.logsHandler = .noOp
        
        await store.send(.exportLogsRequested) { state in
            state.exportOnlyLogs = true
        }
        
        await store.receive(.exportLogs(.start)) { state in
            state.exportLogsState.exportLogsDisabled = true
        }
        
        await store.receive(.exportLogs(.finished(nil))) { state in
            state.exportLogsState.exportLogsDisabled = false
            state.exportLogsState.isSharingLogs = true
            state.isExporting = true
        }
        await store.finish()
    }
    
    func testExportingDoneWhenFinished() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                isExporting: true,
                dataDbURL: [],
                exportLogsState: .initial
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        await store.send(.shareFinished) { state in
            state.isExporting = false
        }
        
        await store.finish()
    }
    
    func testExportURLs_logsOnly() async throws {
        let URLdb = URL(string: "http://db.url")!
        let URLlogs = URL(string: "http://logs.url")!

        let state = PrivateDataConsentReducer.State(
            isExporting: true,
            dataDbURL: [URLdb],
            exportOnlyLogs: true,
            exportLogsState: .init(zippedLogsURLs: [URLlogs])
        )
        
        XCTAssertEqual(state.exportURLs, [URLlogs])
    }
    
    func testExportURLs_dbAndlogs() async throws {
        let URLdb = URL(string: "http://db.url")!
        let URLlogs = URL(string: "http://logs.url")!

        let state = PrivateDataConsentReducer.State(
            isExporting: true,
            dataDbURL: [URLdb],
            exportOnlyLogs: false,
            exportLogsState: .init(zippedLogsURLs: [URLlogs])
        )
        
        XCTAssertEqual(state.exportURLs, [URLdb, URLlogs])
    }
}
