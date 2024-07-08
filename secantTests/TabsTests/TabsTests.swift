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
            Tabs()
        }
        
        await store.send(.home(.walletBalances(.availableBalanceTapped))) { state in
            state.selectedTab = .balances
        }
    }
    
    func testSelectionOfTheTab() async {
        let store = TestStore(
            initialState: .initial
        ) {
            Tabs()
        }
        
        store.dependencies.exchangeRate = .noOp
        
        await store.send(.selectedTabChanged(.send)) { state in
            state.selectedTab = .send
        }
    }
    
    func testSettingDestination() async {
        let store = TestStore(
            initialState: .initial
        ) {
            Tabs()
        }
        
        await store.send(.updateDestination(.settings)) { state in
            state.destination = .settings
        }
    }
    
    func testSettingDestinationDismissal() async {
        var placeholderState = Tabs.State.initial
        placeholderState.destination = .settings
        
        let store = TestStore(
            initialState: placeholderState
        ) {
            Tabs()
        }
        
        await store.send(.updateDestination(nil)) { state in
            state.destination = nil
        }
    }
        
    func testAccountTabTitle() {
        var tabsState = Tabs.State.initial
        tabsState.selectedTab = .account
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.account,
            "Name of the account tab should be '\(L10n.Tabs.account)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendTabTitle() {
        var tabsState = Tabs.State.initial
        tabsState.selectedTab = .send
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.send,
            "Name of the send tab should be '\(L10n.Tabs.send)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testReceiveTabTitle() {
        var tabsState = Tabs.State.initial
        tabsState.selectedTab = .receive
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.receive,
            "Name of the receive tab should be '\(L10n.Tabs.receive)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testDetailsTabTitle() {
        var tabsState = Tabs.State.initial
        tabsState.selectedTab = .balances
        
        XCTAssertEqual(
            tabsState.selectedTab.title,
            L10n.Tabs.balances,
            "Name of the balances tab should be '\(L10n.Tabs.balances)' but received \(tabsState.selectedTab.title)"
        )
    }
    
    func testSendRedirectsBackToAccount() async {
        var placeholderState = Tabs.State.initial
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
            Tabs()
        }
        
        store.dependencies.derivationTool = .noOp
        store.dependencies.numberFormatter = .noOp

        await store.send(.sendConfirmation(.sendDone)) { state in
            state.selectedTab = .account
            state.homeState.transactionListState.transactionList = IdentifiedArrayOf(
                uniqueElements: [
                    TransactionState.placeholder(uuid: "1"),
                    TransactionState.placeholder(uuid: "2")
                ]
            )
        }
        
        await store.receive(.updateDestination(nil))

        await store.receive(.send(.resetForm))

        // TODO: FIXME
//        await store.receive(.send(.transactionAmountInput(.textField(.set("".redacted))))) { state in
//            state.sendState.transactionAmountInputState.textFieldState.valid = true
//        }
//        
//        await store.receive(.send(.transactionAddressInput(.textField(.set("".redacted))))) { state in
//            state.sendState.transactionAddressInputState.textFieldState.valid = true
//        }
//        
//        await store.receive(.send(.transactionAmountInput(.updateAmount)))
    }
    
    func testShieldFundsSucceed() async throws {
        var placeholderState = Tabs.State.initial
        placeholderState.selectedTab = .send
        placeholderState.balanceBreakdownState.walletBalancesState.transparentBalance = Zatoshi(10_000)
        
        let store = TestStore(
            initialState: placeholderState
        ) {
            Tabs()
        }
        
        store.dependencies.sdkSynchronizer = .mock
        let proposal = Proposal.testOnlyFakeProposal(totalFee: 10_000)
        store.dependencies.sdkSynchronizer.proposeShielding = { _, _, _, _ in proposal }
        store.dependencies.sdkSynchronizer.createProposedTransactions = { _, _ in .success }
        store.dependencies.derivationTool = .liveValue
        store.dependencies.mnemonic = .mock
        store.dependencies.walletStorage.exportWallet = { .placeholder }
        store.dependencies.walletStorage.areKeysPresent = { true }

        await store.send(.balanceBreakdown(.shieldFunds)) { state in
            state.balanceBreakdownState.isShieldingFunds = true
        }

        await store.receive(.balanceBreakdown(.walletBalances(.updateBalances)))
        
        await store.receive(.balanceBreakdown(.shieldFundsSuccess)) { state in
            state.balanceBreakdownState.walletBalancesState.transparentBalance = .zero
            state.balanceBreakdownState.isShieldingFunds = false
        }

        let accountBalance = AccountBalance(saplingBalance: .zero, orchardBalance: .zero, unshielded: .zero)
        await store.receive(.balanceBreakdown(.walletBalances(.balancesUpdated(accountBalance))))

        await store.receive(.balanceBreakdown(.updateBalances(accountBalance)))

        await store.finish()
    }
}
