//
//  Tabs.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 09.10.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI

import Generated
import AddressDetails
import BalanceBreakdown
import Home
import SendFlow
import Settings
import ZcashLightClientKit
import RestoreWalletStorage

public typealias TabsStore = Store<TabsReducer.State, TabsReducer.Action>
public typealias TabsViewStore = ViewStore<TabsReducer.State, TabsReducer.Action>

public struct TabsReducer: Reducer {
    let tokenName: String
    let network: ZcashNetwork

    public struct State: Equatable {
        public enum Destination: Equatable {
            case settings
        }

        public enum Tab: Int, CaseIterable {
            case account = 0
            case send
            case receive
            case balances
            
            public var title: String {
                switch self {
                case .account:
                    return L10n.Tabs.account
                case .send:
                    return L10n.Tabs.send
                case .receive:
                    return L10n.Tabs.receive
                case .balances:
                    return L10n.Tabs.balances
                }
            }
        }
        
        public var addressDetailsState: AddressDetailsReducer.State
        public var balanceBreakdownState: BalanceBreakdownReducer.State
        public var destination: Destination?
        public var homeState: HomeReducer.State
        public var isRestoringWallet = false
        public var selectedTab: Tab = .account
        public var sendState: SendFlowReducer.State
        public var settingsState: SettingsReducer.State
        
        public init(
            addressDetailsState: AddressDetailsReducer.State,
            balanceBreakdownState: BalanceBreakdownReducer.State,
            destination: Destination? = nil,
            homeState: HomeReducer.State,
            isRestoringWallet: Bool = false,
            selectedTab: Tab = .account,
            sendState: SendFlowReducer.State,
            settingsState: SettingsReducer.State
        ) {
            self.addressDetailsState = addressDetailsState
            self.balanceBreakdownState = balanceBreakdownState
            self.destination = destination
            self.homeState = homeState
            self.isRestoringWallet = isRestoringWallet
            self.selectedTab = selectedTab
            self.sendState = sendState
            self.settingsState = settingsState
        }
    }
    
    public enum Action: Equatable {
        case addressDetails(AddressDetailsReducer.Action)
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case home(HomeReducer.Action)
        case restoreWalletTask
        case restoreWalletValue(Bool)
        case selectedTabChanged(State.Tab)
        case send(SendFlowReducer.Action)
        case settings(SettingsReducer.Action)
        case updateDestination(TabsReducer.State.Destination?)
    }

    @Dependency(\.restoreWalletStorage) var restoreWalletStorage

    public init(tokenName: String, network: ZcashNetwork) {
        self.tokenName = tokenName
        self.network = network
    }

    public var body: some Reducer<State, Action> {
        Scope(state: \.sendState, action: /Action.send) {
            SendFlowReducer(network: network)
        }
        
        Scope(state: \.addressDetailsState, action: /Action.addressDetails) {
            AddressDetailsReducer(network: network)
        }
        
        Scope(state: \.balanceBreakdownState, action: /Action.balanceBreakdown) {
            BalanceBreakdownReducer(network: network)
        }

        Scope(state: \.homeState, action: /Action.home) {
            HomeReducer(network: network)
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer(network: network)
        }

        Reduce { state, action in
            switch action {
            case .addressDetails:
                return .none
            
            case .balanceBreakdown(.shieldFundsSuccess(let transaction)):
                state.homeState.transactionListState.transactionList.insert(transaction, at: 0)
                return .none
            
            case .balanceBreakdown:
                return .none
                
            case .home(.balanceBreakdown):
                state.selectedTab = .balances
                return .none
                
            case .home:
                return .none
                
            case .restoreWalletTask:
                return .run { send in
                    for await value in await restoreWalletStorage.value() {
                        await send(.restoreWalletValue(value))
                    }
                }

            case .restoreWalletValue(let value):
                state.isRestoringWallet = value
                return .none

            case .send(.sendDone(let transaction)):
                state.homeState.transactionListState.transactionList.insert(transaction, at: 0)
                state.selectedTab = .account
                return .none
            
            case .send:
                return .none

            case .settings:
                return .none

            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                return .none
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none
            }
        }
    }
}

// MARK: - Store

extension TabsStore {
    public static var demo = TabsStore(
        initialState: .initial
    ) {
        TabsReducer(
            tokenName: "TAZ",
            network: ZcashNetworkBuilder.network(for: .testnet)
        )
    }
}

extension TabsStore {
    func settingsStore() -> SettingsStore {
        self.scope(
            state: \.settingsState,
            action: TabsReducer.Action.settings
        )
    }
}

// MARK: - ViewStore

extension TabsViewStore {
    func bindingForDestination(_ destination: TabsReducer.State.Destination) -> Binding<Bool> {
        self.binding(
            get: { $0.destination == destination },
            send: { isActive in .updateDestination(isActive ? destination : nil) }
        )
    }
}

// MARK: - Placeholders

extension TabsReducer.State {
    public static let initial = TabsReducer.State(
        addressDetailsState: .initial,
        balanceBreakdownState: .initial,
        destination: nil,
        homeState: .initial,
        selectedTab: .account,
        sendState: .initial,
        settingsState: .initial
    )
}
