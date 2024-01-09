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
import Models
import Utils
@testable import secant_testnet
@testable import ZcashLightClientKit

@MainActor
class TabsTests: XCTestCase {
    func testHomeBalanceRedirectToTheDetailsTab() async {
        let store = TestStore(
            initialState: .initial
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        await store.send(.home(.balanceBreakdown)) { state in
            state.selectedTab = .balances
        }
    }
    
    func testSelectionOfTheTab() async {
        let store = TestStore(
            initialState: .initial
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        await store.send(.selectedTabChanged(.send)) { state in
            state.selectedTab = .send
        }
    }
    
    func testSettingDestination() async {
        let store = TestStore(
            initialState: .initial
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        await store.send(.updateDestination(.settings)) { state in
            state.destination = .settings
        }
    }
    
    func testSettingDestinationDismissal() async {
        var placeholderState = TabsReducer.State.initial
        placeholderState.destination = .settings
        
        let store = TestStore(
            initialState: placeholderState
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        await store.send(.updateDestination(nil)) { state in
            state.destination = nil
        }
    }
    
    func testRestoreWalletSubscription() async throws {
        var initialState = TabsReducer.State.initial
        initialState.isRestoringWallet = false

        let store = TestStore(
            initialState: initialState
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
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
    
    func testAccountTabTitle() {
        var tabsState = TabsReducer.State.initial
        tabsState.selectedTab = .account
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.account,
            "Name of the account tab should be '\(L10n.Tabs.account)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendTabTitle() {
        var tabsState = TabsReducer.State.initial
        tabsState.selectedTab = .send
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.send,
            "Name of the send tab should be '\(L10n.Tabs.send)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testReceiveTabTitle() {
        var tabsState = TabsReducer.State.initial
        tabsState.selectedTab = .receive
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.receive,
            "Name of the receive tab should be '\(L10n.Tabs.receive)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testDetailsTabTitle() {
        var tabsState = TabsReducer.State.initial
        tabsState.selectedTab = .balances
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.balances,
            "Name of the balances tab should be '\(L10n.Tabs.balances)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendRedirectsBackToAccount() async {
        var placeholderState = TabsReducer.State.initial
        placeholderState.selectedTab = .send
        
        placeholderState.homeState.transactionListState.transactionList = IdentifiedArrayOf(
            uniqueElements: [
                TransactionState.placeholder(uuid: "1"),
                TransactionState.placeholder(uuid: "2")
            ]
        )
        
        let store = TestStore(
            initialState: placeholderState
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        let transaction = TransactionState.placeholder(uuid: "3")
        
        await store.send(.send(.sendDone(transaction))) { state in
            state.selectedTab = .account
            state.homeState.transactionListState.transactionList = IdentifiedArrayOf(
                uniqueElements: [
                    transaction,
                    TransactionState.placeholder(uuid: "1"),
                    TransactionState.placeholder(uuid: "2")
                ]
            )
        }
    }
    
    func testShieldFundsSucceedAndTransactionListUpdated() async throws {
        var placeholderState = TabsReducer.State.initial
        placeholderState.selectedTab = .send
        placeholderState.balanceBreakdownState.transparentBalance = Balance(WalletBalance(verified: Zatoshi(10_000), total: Zatoshi(10_000)))
        
        let store = TestStore(
            initialState: placeholderState
        ) {
            TabsReducer(tokenName: "TAZ", networkType: .testnet)
        }
        
        store.dependencies.sdkSynchronizer = .mock
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.balanceBreakdown(.shieldFunds)) { state in
            state.balanceBreakdownState.isShieldingFunds = true
        }
        
        let shieldedTransaction = TransactionState(
            expiryHeight: 40,
            memos: [try Memo(string: "")],
            minedHeight: 50,
            shielded: true,
            zAddress: "tteafadlamnelkqe",
            fee: Zatoshi(10),
            id: "id",
            status: .paid,
            timestamp: 1234567,
            zecAmount: Zatoshi(10)
        )
        
        await store.receive(.balanceBreakdown(.shieldFundsSuccess(shieldedTransaction))) { state in
            state.balanceBreakdownState.isShieldingFunds = false
            state.balanceBreakdownState.transparentBalance = .zero
            state.homeState.transactionListState.transactionList = IdentifiedArrayOf(uniqueElements: [shieldedTransaction])
        }
        
        await store.finish()
    }
}
