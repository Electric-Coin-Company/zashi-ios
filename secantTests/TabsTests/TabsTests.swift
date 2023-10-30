//
//  TabsTests.swift
//  secantTests
//
//  Created by Lukáš Korba on 10.10.2023.
//

import Combine
import XCTest
import ComposableArchitecture
import Tabs
import Generated
@testable import secant_testnet
@testable import ZcashLightClientKit

@MainActor
class TabsTests: XCTestCase {
    func testHomeBalanceRedirectToTheDetailsTab() async {
        let store = TestStore(
            initialState: .placeholder,
            reducer: { TabsReducer(tokenName: "TAZ", networkType: .testnet) }
        )
        
        await store.send(.home(.balanceBreakdown)) { state in
            state.selectedTab = .balances
        }
    }
    
    func testSelectionOfTheTab() async {
        let store = TestStore(
            initialState: .placeholder,
            reducer: { TabsReducer(tokenName: "TAZ", networkType: .testnet) }
        )
        
        await store.send(.selectedTabChanged(.send)) { state in
            state.selectedTab = .send
        }
    }
    
    func testSettingDestination() async {
        let store = TestStore(
            initialState: .placeholder,
            reducer: { TabsReducer(tokenName: "TAZ", networkType: .testnet) }
        )
        
        await store.send(.updateDestination(.settings)) { state in
            state.destination = .settings
        }
    }
    
    func testSettingDestinationDismissal() async {
        var placeholderState = TabsReducer.State.placeholder
        placeholderState.destination = .settings
        
        let store = TestStore(
            initialState: placeholderState,
            reducer: { TabsReducer(tokenName: "TAZ", networkType: .testnet) }
        )
        
        await store.send(.updateDestination(nil)) { state in
            state.destination = nil
        }
    }
    
    func testAccountTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .account
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.account,
            "Name of the account tab should be '\(L10n.Tabs.account)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .send
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.send,
            "Name of the send tab should be '\(L10n.Tabs.send)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testReceiveTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .receive
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.receive,
            "Name of the receive tab should be '\(L10n.Tabs.receive)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testDetailsTabTitle() {
        var tabsState = TabsReducer.State.placeholder
        tabsState.selectedTab = .balances
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.balances,
            "Name of the balances tab should be '\(L10n.Tabs.balances)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendRedirectsBackToAccount() async {
        var placeholderState = TabsReducer.State.placeholder
        placeholderState.selectedTab = .send
        
        let store = TestStore(
            initialState: placeholderState,
            reducer: { TabsReducer(tokenName: "TAZ", networkType: .testnet) }
        )
        
        await store.send(.send(.sendDone)) { state in
            state.selectedTab = .account
        }
    }
}
