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
    
    func testClearOutAcknowledgeConfirmation() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                isAcknowledged: true,
                dataDbURL: [],
                exportBinding: false,
                exportLogsState: .initial
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        let URL = URL(string: "https://electriccoin.co")!
        
        store.dependencies.databaseFiles.dataDbURLFor = { _ in URL }
        
        await store.send(.onAppear) { state in
            state.dataDbURL = [URL]
            state.isAcknowledged = false
        }
        
        await store.finish()
    }
    
    func testExportRequestSet() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                dataDbURL: [],
                exportBinding: false,
                exportLogsState: .initial,
                exportOnlyLogs: true
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.dependencies.logsHandler = .noOp
        
        await store.send(.exportRequested) { state in
            state.exportOnlyLogs = false
            state.isExportingData = true
        }
        
        await store.receive(.exportLogs(.start)) { state in
            state.exportLogsState.exportLogsDisabled = true
        }
        
        await store.receive(.exportLogs(.finished(nil))) { state in
            state.exportLogsState.exportLogsDisabled = false
            state.exportLogsState.isSharingLogs = true
            state.exportBinding = true
        }

        await store.finish()
    }
    
    func testExportLogsRequestSet() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                dataDbURL: [],
                exportBinding: false,
                exportLogsState: .initial,
                exportOnlyLogs: false
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        store.dependencies.logsHandler = .noOp
        
        await store.send(.exportLogsRequested) { state in
            state.exportOnlyLogs = true
            state.isExportingLogs = true
        }
        
        await store.receive(.exportLogs(.start)) { state in
            state.exportLogsState.exportLogsDisabled = true
        }
        
        await store.receive(.exportLogs(.finished(nil))) { state in
            state.exportLogsState.exportLogsDisabled = false
            state.exportLogsState.isSharingLogs = true
            state.exportBinding = true
        }
        await store.finish()
    }
    
    func testExportingDoneWhenFinished() async throws {
        let store = TestStore(
            initialState: PrivateDataConsentReducer.State(
                dataDbURL: [],
                exportBinding: true,
                exportLogsState: .initial,
                isExportingData: true,
                isExportingLogs: true
            )
        ) {
            PrivateDataConsentReducer(networkType: .testnet)
        }
        
        await store.send(.shareFinished) { state in
            state.exportBinding = false
            state.isExportingData = false
            state.isExportingLogs = false
        }
        
        await store.finish()
    }
    
    func testExportURLs_logsOnly() async throws {
        let URLdb = URL(string: "http://db.url")!
        let URLlogs = URL(string: "http://logs.url")!

        let state = PrivateDataConsentReducer.State(
            dataDbURL: [URLdb],
            exportBinding: true,
            exportLogsState: .init(zippedLogsURLs: [URLlogs]),
            exportOnlyLogs: true
        )
        
        XCTAssertEqual(state.exportURLs, [URLlogs])
    }
    
    func testExportURLs_dbAndlogs() async throws {
        let URLdb = URL(string: "http://db.url")!
        let URLlogs = URL(string: "http://logs.url")!

        let state = PrivateDataConsentReducer.State(
            dataDbURL: [URLdb],
            exportBinding: true,
            exportLogsState: .init(zippedLogsURLs: [URLlogs]),
            exportOnlyLogs: false
        )
        
        XCTAssertEqual(state.exportURLs, [URLdb, URLlogs])
    }
    
    func testIsExportPossible_NoBecauseNotAcknowledged() async throws {
        let state = PrivateDataConsentReducer.State(
            isAcknowledged: false,
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible_NoBecauseExportingLogs() async throws {
        let state = PrivateDataConsentReducer.State(
            isAcknowledged: true,
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isExportingLogs: true
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible_NoBecauseExportingData() async throws {
        let state = PrivateDataConsentReducer.State(
            isAcknowledged: true,
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isExportingData: true
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible() async throws {
        let state = PrivateDataConsentReducer.State(
            isAcknowledged: true,
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true
        )
        
        XCTAssertTrue(state.isExportPossible)
    }
}
