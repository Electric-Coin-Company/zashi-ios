//
//  DebugTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 02.03.2023.
//

import XCTest
@testable import secant_testnet
import ComposableArchitecture

@MainActor
class DebugTests: XCTestCase {
    func testRescanBlockchain() async throws {
        let store = TestStore(
            initialState: .placeholder,
            reducer: RootReducer()
        )
        
        await store.send(.debug(.rescanBlockchain)) { state in
            state.debugState.rescanDialog = .init(
                title: TextState("Rescan"),
                message: TextState("Select the rescan you want"),
                buttons: [
                    .default(TextState("Quick rescan"), action: .send(.debug(.quickRescan))),
                    .default(TextState("Full rescan"), action: .send(.debug(.fullRescan))),
                    .cancel(TextState("Cancel"))
                ]
            )
        }
    }
    
    func testRescanBlockchain_Cancelling() async throws {
        var mockState = RootReducer.State.placeholder
        
        mockState.debugState.rescanDialog = .init(
            title: TextState("Rescan"),
            message: TextState("Select the rescan you want"),
            buttons: [
                .default(TextState("Quick rescan"), action: .send(.debug(.quickRescan))),
                .default(TextState("Full rescan"), action: .send(.debug(.fullRescan))),
                .cancel(TextState("Cancel"))
            ]
        )
        
        let store = TestStore(
            initialState: mockState,
            reducer: RootReducer()
        )
        
        await store.send(.debug(.cancelRescan)) { state in
            state.debugState.rescanDialog = nil
        }
    }
    
    func testRescanBlockchain_QuickRescanClearance() async throws {
        var mockState = RootReducer.State.placeholder
        
        mockState.debugState.rescanDialog = .init(
            title: TextState("Rescan"),
            message: TextState("Select the rescan you want"),
            buttons: [
                .default(TextState("Quick rescan"), action: .send(.debug(.quickRescan))),
                .default(TextState("Full rescan"), action: .send(.debug(.fullRescan))),
                .cancel(TextState("Cancel"))
            ]
        )
        
        let store = TestStore(
            initialState: mockState,
            reducer: RootReducer()
        )

        await store.send(.debug(.quickRescan)) { state in
            state.destinationState.internalDestination = .home
            state.destinationState.previousDestination = .welcome
        }
        
        await store.receive(.debug(.rewindDone(nil, .debug(.quickRescan))))
    }
    
    func testRescanBlockchain_FullRescanClearance() async throws {
        var mockState = RootReducer.State.placeholder
        
        mockState.debugState.rescanDialog = .init(
            title: TextState("Rescan"),
            message: TextState("Select the rescan you want"),
            buttons: [
                .default(TextState("Quick rescan"), action: .send(.debug(.quickRescan))),
                .default(TextState("Full rescan"), action: .send(.debug(.fullRescan))),
                .cancel(TextState("Cancel"))
            ]
        )
        
        let store = TestStore(
            initialState: mockState,
            reducer: RootReducer()
        )
                
        await store.send(.debug(.fullRescan)) { state in
            state.destinationState.internalDestination = .home
            state.destinationState.previousDestination = .welcome
        }
        
        await store.receive(.debug(.rewindDone(nil, .debug(.fullRescan))))
    }
}
