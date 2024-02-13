//
//  PrivateDataConsentTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 01.11.2023.
//

import XCTest
import ComposableArchitecture
import PrivateDataConsent
import ZcashLightClientKit
@testable import secant_testnet

@MainActor
final class PrivateDataConsentTests: XCTestCase {
    func testURLsProperlyPrepared() async throws {
        let store = TestStore(
            initialState: .initial
        ) {
            PrivateDataConsentReducer(network: ZcashNetworkBuilder.network(for: .testnet))
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
                dataDbURL: [],
                exportBinding: false,
                exportLogsState: .initial,
                exportOnlyLogs: true
            )
        ) {
            PrivateDataConsentReducer(network: ZcashNetworkBuilder.network(for: .testnet))
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
            PrivateDataConsentReducer(network: ZcashNetworkBuilder.network(for: .testnet))
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
            PrivateDataConsentReducer(network: ZcashNetworkBuilder.network(for: .testnet))
        }
        
        await store.send(.shareFinished) { state in
            state.exportBinding = false
            state.isExportingData = false
            state.isExportingLogs = false
        }
        
        await store.finish()
    }
    
    func testRestoreWalletSubscription() async throws {
        var initialState = PrivateDataConsentReducer.State.initial
        initialState.isRestoringWallet = false

        let store = TestStore(
            initialState: initialState
        ) {
            PrivateDataConsentReducer(network: ZcashNetworkBuilder.network(for: .testnet))
        }

        store.dependencies.restoreWalletStorage = .noOp
        store.dependencies.restoreWalletStorage.value = {
            AsyncStream { continuation in
                continuation.yield(true)
                continuation.finish()
            }
        }
        
        await store.send(.restoreWalletTask)
        
        await store.receive(.restoreWalletValue(true)) { state in
            state.isRestoringWallet = true
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
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isAcknowledged: false
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible_NoBecauseExportingLogs() async throws {
        let state = PrivateDataConsentReducer.State(
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isAcknowledged: true,
            isExportingLogs: true
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible_NoBecauseExportingData() async throws {
        let state = PrivateDataConsentReducer.State(
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isAcknowledged: true,
            isExportingData: true
        )
        
        XCTAssertFalse(state.isExportPossible)
    }
    
    func testIsExportPossible() async throws {
        let state = PrivateDataConsentReducer.State(
            dataDbURL: [],
            exportBinding: true,
            exportLogsState: .initial,
            exportOnlyLogs: true,
            isAcknowledged: true
        )
        
        XCTAssertTrue(state.isExportPossible)
    }
}
