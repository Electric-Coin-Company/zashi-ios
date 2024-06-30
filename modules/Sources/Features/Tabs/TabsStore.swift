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
import SendConfirmation
import RequestPayment

public typealias TabsStore = Store<TabsReducer.State, TabsReducer.Action>
public typealias TabsViewStore = ViewStore<TabsReducer.State, TabsReducer.Action>

public struct TabsReducer: Reducer {
    public struct State: Equatable {
        public enum Destination: Equatable {
            case requestPaymentConfirmation
            case requestPaymentForm
            case sendConfirmation
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
        
        public var addressDetailsState: AddressDetails.State
        public var balanceBreakdownState: BalanceBreakdownReducer.State
        public var destination: Destination?
        public var homeState: Home.State
        public var requestPaymentState: RequestPayment.State
        public var selectedTab: Tab = .account
        public var sendConfirmationState: SendConfirmation.State
        public var sendState: SendFlowReducer.State
        public var settingsState: SettingsReducer.State
        
        public init(
            addressDetailsState: AddressDetails.State,
            balanceBreakdownState: BalanceBreakdownReducer.State,
            destination: Destination? = nil,
            homeState: Home.State,
            requestPaymentState: RequestPayment.State,
            selectedTab: Tab = .account,
            sendConfirmationState: SendConfirmation.State,
            sendState: SendFlowReducer.State,
            settingsState: SettingsReducer.State
        ) {
            self.addressDetailsState = addressDetailsState
            self.balanceBreakdownState = balanceBreakdownState
            self.destination = destination
            self.homeState = homeState
            self.requestPaymentState = requestPaymentState
            self.selectedTab = selectedTab
            self.sendConfirmationState = sendConfirmationState
            self.sendState = sendState
            self.settingsState = settingsState
        }
    }
    
    public enum Action: Equatable {
        case addressDetails(AddressDetails.Action)
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case home(Home.Action)
        case requestPayment(RequestPayment.Action)
        case selectedTabChanged(State.Tab)
        case send(SendFlowReducer.Action)
        case sendConfirmation(SendConfirmation.Action)
        case settings(SettingsReducer.Action)
        case updateDestination(TabsReducer.State.Destination?)
    }

    @Dependency(\.mainQueue) var mainQueue

    public init() { }

    public var body: some Reducer<State, Action> {
        Scope(state: \.sendState, action: /Action.send) {
            SendFlowReducer()
        }

        Scope(state: \.sendConfirmationState, action: /Action.sendConfirmation) {
            SendConfirmation()
        }

        Scope(state: \.addressDetailsState, action: /Action.addressDetails) {
            AddressDetails()
        }
        
        Scope(state: \.balanceBreakdownState, action: /Action.balanceBreakdown) {
            BalanceBreakdownReducer()
        }

        Scope(state: \.homeState, action: /Action.home) {
            Home()
        }

        Scope(state: \.requestPaymentState, action: /Action.requestPayment) {
            RequestPayment()
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
        }

        Reduce { state, action in
            switch action {
            case .addressDetails(.requestPaymentTapped):
                if state.addressDetailsState.selection == .transparent {
                    state.requestPaymentState.toAddress = state.addressDetailsState.transparentAddress
                    state.requestPaymentState.isMemoPossible = false
                } else {
                    state.requestPaymentState.toAddress = state.addressDetailsState.unifiedAddress
                    state.requestPaymentState.isMemoPossible = true
                }
                return .send(.updateDestination(.requestPaymentForm))
                
            case .addressDetails:
                return .none

            case .balanceBreakdown(.shieldFundsSuccess):
                return .none
            
            case .balanceBreakdown:
                return .none
                
            case .home(.walletBalances(.availableBalanceTapped)),
                .send(.walletBalances(.availableBalanceTapped)):
                state.selectedTab = .balances
                return .none
                
            case .home:
                return .none
                
            case .requestPayment:
                return .none

            case .send(.confirmationRequired(let type)):
                state.isRPConnected = type == .requestPayment
                state.sendConfirmationState.amount = state.sendState.amount
                state.sendConfirmationState.address = state.sendState.address
                state.sendConfirmationState.feeRequired = state.sendState.feeRequired
                state.sendConfirmationState.message = state.sendState.message
                state.sendConfirmationState.isInsufficientFunds = state.sendState.isInsufficientFunds
                return .send(.updateDestination(type == .send ? .sendConfirmation : .requestPaymentConfirmation))
                
            case .send(.proposal(let proposal)):
                state.sendConfirmationState.proposal = proposal
                return .none
                
            case .send(.walletBalances(.balancesUpdated)):
                state.sendConfirmationState.isInsufficientFunds = state.sendState.isInsufficientFunds
                if state.isRPConnected && !state.sendState.isInsufficientFunds && state.sendConfirmationState.proposal == nil {
                    state.isRPConnected = false
                    return .send(.send(.getProposal(.requestPayment)))
                }
                return .none
                                
            case .send:
                return .none

            case .sendConfirmation(.sendPartial):
                state.selectedTab = .send
                return .none

            case .sendConfirmation(.sendDone):
                state.selectedTab = .account
                return .merge(
                    .send(.updateDestination(nil)),
                    .send(.send(.resetForm))
                    )
                
            case .sendConfirmation(.partialProposalError(.dismiss)):
                return .run { send in
                    await send(.updateDestination(nil))
                    try? await mainQueue.sleep(for: .seconds(0.5))
                    await send(.sendConfirmation(.partialProposalErrorDismiss))
                }

            case .sendConfirmation(.goBackPressed):
                return .send(.updateDestination(nil))

            case .sendConfirmation:
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
        TabsReducer()
    }
}

extension TabsStore {
    func settingsStore() -> SettingsStore {
        self.scope(
            state: \.settingsState,
            action: TabsReducer.Action.settings
        )
    }
    
    func sendConfirmationStore() -> StoreOf<SendConfirmation> {
        self.scope(
            state: \.sendConfirmationState,
            action: TabsReducer.Action.sendConfirmation
        )
    }
    
    func requestPaymentStore() -> StoreOf<RequestPayment> {
        self.scope(
            state: \.requestPaymentState,
            action: TabsReducer.Action.requestPayment
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
        requestPaymentState: .initial,
        selectedTab: .account,
        sendConfirmationState: .initial,
        sendState: .initial,
        settingsState: .initial
    )
}
