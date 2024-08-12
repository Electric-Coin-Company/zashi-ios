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
import Utils
import ExchangeRate
import CurrencyConversionSetup
import UserPreferencesStorage

public typealias TabsStore = Store<TabsReducer.State, TabsReducer.Action>
public typealias TabsViewStore = ViewStore<TabsReducer.State, TabsReducer.Action>

public struct TabsReducer: Reducer {
    public struct State: Equatable {
        public enum Destination: Equatable {
            case currencyConversionSetup
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
        public var currencyConversionSetupState: CurrencyConversionSetup.State
        public var destination: Destination?
        public var isRateEducationEnabled = false
        public var isRateTooltipEnabled = false
        public var homeState: Home.State
        public var selectedTab: Tab = .account
        public var sendConfirmationState: SendConfirmation.State
        public var sendState: SendFlowReducer.State
        public var settingsState: SettingsReducer.State
        
        public init(
            addressDetailsState: AddressDetails.State,
            balanceBreakdownState: BalanceBreakdownReducer.State,
            currencyConversionSetupState: CurrencyConversionSetup.State,
            destination: Destination? = nil,
            isRateEducationEnabled: Bool = false,
            isRateTooltipEnabled: Bool = false,
            homeState: Home.State,
            selectedTab: Tab = .account,
            sendConfirmationState: SendConfirmation.State,
            sendState: SendFlowReducer.State,
            settingsState: SettingsReducer.State
        ) {
            self.addressDetailsState = addressDetailsState
            self.balanceBreakdownState = balanceBreakdownState
            self.currencyConversionSetupState = currencyConversionSetupState
            self.destination = destination
            self.isRateEducationEnabled = isRateEducationEnabled
            self.isRateTooltipEnabled = isRateTooltipEnabled
            self.homeState = homeState
            self.selectedTab = selectedTab
            self.sendConfirmationState = sendConfirmationState
            self.sendState = sendState
            self.settingsState = settingsState
        }
    }
    
    public enum Action: Equatable {
        case addressDetails(AddressDetails.Action)
        case balanceBreakdown(BalanceBreakdownReducer.Action)
        case currencyConversionCloseTapped
        case currencyConversionSetup(CurrencyConversionSetup.Action)
        case home(Home.Action)
        case onAppear
        case rateTooltipTapped
        case selectedTabChanged(State.Tab)
        case send(SendFlowReducer.Action)
        case sendConfirmation(SendConfirmation.Action)
        case settings(SettingsReducer.Action)
        case updateDestination(TabsReducer.State.Destination?)
    }

    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userStoredPreferences) var userStoredPreferences

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
        
        Scope(state: \.currencyConversionSetupState, action: /Action.currencyConversionSetup) {
            CurrencyConversionSetup()
        }

        Scope(state: \.balanceBreakdownState, action: /Action.balanceBreakdown) {
            BalanceBreakdownReducer()
        }

        Scope(state: \.homeState, action: /Action.home) {
            Home()
        }

        Scope(state: \.settingsState, action: /Action.settings) {
            SettingsReducer()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isRateEducationEnabled = userStoredPreferences.exchangeRate() == nil
                return .none
                
            case .addressDetails:
                return .none
            
            case .balanceBreakdown(.shieldFundsSuccess):
                return .none
            
            case .balanceBreakdown:
                return .none

            case .currencyConversionCloseTapped:
                state.isRateEducationEnabled = false
                try? userStoredPreferences.setExchangeRate(UserPreferencesStorage.ExchangeRate(manual: true, automatic: false))
                return .none
                
            case .currencyConversionSetup(.enableTapped), .currencyConversionSetup(.skipTapped):
                state.isRateEducationEnabled = false
                return .send(.updateDestination(nil))
                
            case .currencyConversionSetup:
                return .none
                
            case .home(.walletBalances(.availableBalanceTapped)),
                .send(.walletBalances(.availableBalanceTapped)):
                state.selectedTab = .balances
                return .none
                
            case .home(.walletBalances(.exchangeRateRefreshTapped)):
                if state.isRateTooltipEnabled {
                    state.isRateTooltipEnabled = false
                    return .none
                }
                state.isRateTooltipEnabled = state.homeState.walletBalancesState.isExchangeRateStale
                return .none
                
            case .home:
                return .none
            
            case .settings(.advancedSettings(.currencyConversionSetup(.saveChangesTapped))):
                return .send(.send(.exchangeRateSetupChanged))
                
            case .send(.sendConfirmationRequired):
                state.sendConfirmationState.amount = state.sendState.amount
                state.sendConfirmationState.address = state.sendState.address.data
                state.sendConfirmationState.proposal = state.sendState.proposal
                state.sendConfirmationState.feeRequired = state.sendState.feeRequired
                state.sendConfirmationState.message = state.sendState.message
                state.sendConfirmationState.currencyAmount = state.sendState.currencyConversion?.convert(state.sendState.amount).redacted ?? .empty
                return .send(.updateDestination(.sendConfirmation))
                                
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
                if tab == .send {
                    exchangeRate.refreshExchangeRateUSD()
                }
                return .none
                
            case .updateDestination(.currencyConversionSetup):
                state.destination = .currencyConversionSetup
                return .send(.currencyConversionCloseTapped)
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none
                
            case .rateTooltipTapped:
                state.isRateTooltipEnabled = false
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
    
    func currencyConversionSetupStore() -> StoreOf<CurrencyConversionSetup> {
        self.scope(
            state: \.currencyConversionSetupState,
            action: TabsReducer.Action.currencyConversionSetup
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
        currencyConversionSetupState: .initial,
        destination: nil,
        homeState: .initial,
        selectedTab: .account,
        sendConfirmationState: .initial,
        sendState: .initial,
        settingsState: .initial
    )
}
