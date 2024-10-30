//
//  Tabs.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 09.10.2023.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import UIKit

import AddressDetails
import Generated
import Receive
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
import RequestZec
import ZecKeyboard
import AddressBook
import Models

@Reducer
public struct Tabs {
    @ObservableState
    public struct State: Equatable {
        public enum Destination: Equatable {
            case addressDetails
            case currencyConversionSetup
            case sendConfirmation
            case settings
        }

        public enum StackDestinationLowPrivacy: Int, Equatable {
            case zecKeyboard = 0
            case requestZecSummary
        }

        public enum StackDestinationMaxPrivacy: Int, Equatable {
            case zecKeyboard = 0
            case requestZec
            case requestZecSummary
        }

        public enum StackDestinationRequestPayment: Int, Equatable {
            case requestPaymentConfirmation = 0
            case addressBookNewContact
        }

        public enum Tab: Int, Equatable, CaseIterable {
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

        public var addressBookState: AddressBook.State = .initial
        public var addressDetailsState: AddressDetails.State
        public var balanceBreakdownState: Balances.State
        public var currencyConversionSetupState: CurrencyConversionSetup.State
        public var destination: Destination?
        @Shared(.inMemory(.featureFlags)) public var featureFlags: FeatureFlags = .initial
        public var isRateEducationEnabled = false
        public var isRateTooltipEnabled = false
        public var homeState: Home.State
        public var receiveState: Receive.State
        public var requestZecState: RequestZec.State
        public var selectedTab: Tab = .account
        public var sendConfirmationState: SendConfirmation.State
        public var sendState: SendFlow.State
        public var settingsState: Settings.State
        public var stackDestinationLowPrivacy: StackDestinationLowPrivacy?
        public var stackDestinationLowPrivacyBindingsAlive = 0
        public var stackDestinationMaxPrivacy: StackDestinationMaxPrivacy?
        public var stackDestinationMaxPrivacyBindingsAlive = 0
        public var stackDestinationRequestPayment: StackDestinationRequestPayment?
        public var stackDestinationRequestPaymentBindingsAlive = 0
        public var zecKeyboardState: ZecKeyboard.State
        
        public init(
            addressDetailsState: AddressDetails.State = .initial,
            balanceBreakdownState: Balances.State,
            currencyConversionSetupState: CurrencyConversionSetup.State,
            destination: Destination? = nil,
            isRateEducationEnabled: Bool = false,
            isRateTooltipEnabled: Bool = false,
            homeState: Home.State,
            receiveState: Receive.State,
            requestZecState: RequestZec.State,
            selectedTab: Tab = .account,
            sendConfirmationState: SendConfirmation.State,
            sendState: SendFlow.State,
            settingsState: Settings.State,
            zecKeyboardState: ZecKeyboard.State
        ) {
            self.addressDetailsState = addressDetailsState
            self.balanceBreakdownState = balanceBreakdownState
            self.currencyConversionSetupState = currencyConversionSetupState
            self.destination = destination
            self.isRateEducationEnabled = isRateEducationEnabled
            self.isRateTooltipEnabled = isRateTooltipEnabled
            self.homeState = homeState
            self.receiveState = receiveState
            self.requestZecState = requestZecState
            self.selectedTab = selectedTab
            self.sendConfirmationState = sendConfirmationState
            self.sendState = sendState
            self.settingsState = settingsState
            self.zecKeyboardState = zecKeyboardState
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case addressBook(AddressBook.Action)
        case addressDetails(AddressDetails.Action)
        case balanceBreakdown(Balances.Action)
        case binding(BindingAction<Tabs.State>)
        case currencyConversionCloseTapped
        case currencyConversionSetup(CurrencyConversionSetup.Action)
        case home(Home.Action)
        case onAppear
        case rateTooltipTapped
        case receive(Receive.Action)
        case requestZec(RequestZec.Action)
        case selectedTabChanged(State.Tab)
        case send(SendFlow.Action)
        case sendConfirmation(SendConfirmation.Action)
        case settings(Settings.Action)
        case updateDestination(Tabs.State.Destination?)
        case updateStackDestinationLowPrivacy(Tabs.State.StackDestinationLowPrivacy?)
        case updateStackDestinationMaxPrivacy(Tabs.State.StackDestinationMaxPrivacy?)
        case updateStackDestinationRequestPayment(Tabs.State.StackDestinationRequestPayment?)
        case zecKeyboard(ZecKeyboard.Action)
    }

    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.userStoredPreferences) var userStoredPreferences

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Scope(state: \.addressBookState, action: \.addressBook) {
            AddressBook()
        }

        Scope(state: \.sendState, action: \.send) {
            SendFlow()
        }

        Scope(state: \.sendConfirmationState, action: \.sendConfirmation) {
            SendConfirmation()
        }

        Scope(state: \.receiveState, action: \.receive) {
            Receive()
        }

        Scope(state: \.requestZecState, action: \.requestZec) {
            RequestZec()
        }

        Scope(state: \.currencyConversionSetupState, action: \.currencyConversionSetup) {
            CurrencyConversionSetup()
        }

        Scope(state: \.balanceBreakdownState, action: \.balanceBreakdown) {
            Balances()
        }

        Scope(state: \.homeState, action: \.home) {
            Home()
        }

        Scope(state: \.settingsState, action: \.settings) {
            Settings()
        }

        Scope(state: \.addressDetailsState, action: \.addressDetails) {
            AddressDetails()
        }

        Scope(state: \.zecKeyboardState, action: \.zecKeyboard) {
            ZecKeyboard()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isRateEducationEnabled = userStoredPreferences.exchangeRate() == nil
                return .none
                
            case let .receive(.addressDetailsRequest(address, maxPrivacy)):
                state.addressDetailsState.address = address
                state.addressDetailsState.maxPrivacy = maxPrivacy
                state.addressDetailsState.addressTitle = maxPrivacy
                ? L10n.Receive.shieldedAddress
                : L10n.Receive.transparentAddress
                return .send(.updateDestination(.addressDetails))

            case let .receive(.requestTapped(address, maxPrivacy)):
                state.zecKeyboardState.input = "0"
                state.requestZecState.address = address
                state.requestZecState.maxPrivacy = maxPrivacy
                state.requestZecState.memoState = .initial
                if maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.zecKeyboard))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(.zecKeyboard))
                }

            case .zecKeyboard(.nextTapped):
                state.requestZecState.requestedZec = state.zecKeyboardState.amount
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.requestZec))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(.requestZecSummary))
                }
                
            case .requestZec(.requestTapped):
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(.requestZecSummary))
                }
                return .none
                
            case .requestZec(.cancelRequestTapped):
                if state.requestZecState.maxPrivacy {
                    return .send(.updateStackDestinationMaxPrivacy(nil))
                } else {
                    return .send(.updateStackDestinationLowPrivacy(nil))
                }
                
            case .sendConfirmation(.saveAddressTapped(let address)):
                state.addressBookState.address = address.data
                state.addressBookState.name = ""
                state.addressBookState.isValidZcashAddress = true
                state.addressBookState.isNameFocused = true
                return .send(.updateStackDestinationRequestPayment(.addressBookNewContact))

            case .addressBook(.saveButtonTapped):
                return .send(.updateStackDestinationRequestPayment(.requestPaymentConfirmation))

            case .home(.walletBalances(.exchangeRateRefreshTapped)), .send(.walletBalances(.exchangeRateRefreshTapped)), .balanceBreakdown(.walletBalances(.exchangeRateRefreshTapped)):
                if state.isRateTooltipEnabled {
                    state.isRateTooltipEnabled = false
                    return .none
                }
                state.isRateTooltipEnabled = state.homeState.walletBalancesState.isExchangeRateStale
                return .none

            case .addressBook:
                return .none

            case .addressDetails:
                return .none

            case .binding:
                return .none
                
            case .receive:
                return .none
            
            case .requestZec:
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

            case .home:
                return .none
            
            case .settings(.advancedSettings(.currencyConversionSetup(.saveChangesTapped))):
                return .send(.send(.exchangeRateSetupChanged))
                
            case .send(.confirmationRequired(let type)):
                state.sendConfirmationState.amount = state.sendState.amount
                state.sendConfirmationState.address = state.sendState.address.data
                state.sendConfirmationState.proposal = state.sendState.proposal
                state.sendConfirmationState.feeRequired = state.sendState.feeRequired
                state.sendConfirmationState.message = state.sendState.message
                state.sendConfirmationState.currencyAmount = state.sendState.currencyConversion?.convert(state.sendState.amount).redacted ?? .empty
                if type == .send {
                    return .send(.updateDestination(.sendConfirmation))
                } else {
                    return .send(.updateStackDestinationRequestPayment(.requestPaymentConfirmation))
                }
                                
            case .send:
                return .none

            case .sendConfirmation(.sendPartial):
                state.selectedTab = .send
                return .none

            case .sendConfirmation(.sendDone):
                if state.featureFlags.sendingScreen {
                    return .none
                } else {
                    state.selectedTab = .account
                    return .merge(
                        .send(.updateDestination(nil)),
                        .send(.updateStackDestinationRequestPayment(nil)),
                        .send(.send(.resetForm))
                    )
                }

            case .sendConfirmation(.closeTapped):
                state.selectedTab = .account
                return .merge(
                    .send(.updateDestination(nil)),
                    .send(.updateStackDestinationRequestPayment(nil)),
                    .send(.sendConfirmation(.updateDestination(nil))),
                    .send(.sendConfirmation(.updateResult(nil))),
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

            case .sendConfirmation(.goBackPressedFromRequestZec):
                state.sendState.address = .empty
                state.sendState.memoState.text = ""
                state.sendState.zecAmountText = .empty
                state.sendState.currencyText = .empty
                return .send(.updateStackDestinationRequestPayment(nil))

            case .sendConfirmation:
                return .none

            case .settings:
                return .none

            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                if tab == .send {
                    exchangeRate.refreshExchangeRateUSD()
                }
                state.isRateTooltipEnabled = false
                return .none
                
            case .updateDestination(.currencyConversionSetup):
                state.destination = .currencyConversionSetup
                return .send(.currencyConversionCloseTapped)
                
            case .updateDestination(let destination):
                state.destination = destination
                return .none

            case .updateStackDestinationLowPrivacy(let destination):
                if let destination {
                    state.stackDestinationLowPrivacyBindingsAlive = destination.rawValue
                }
                state.stackDestinationLowPrivacy = destination
                return .none

            case .updateStackDestinationMaxPrivacy(let destination):
                if let destination {
                    state.stackDestinationMaxPrivacyBindingsAlive = destination.rawValue
                }
                state.stackDestinationMaxPrivacy = destination
                return .none

            case .updateStackDestinationRequestPayment(let destination):
                if let destination {
                    state.stackDestinationRequestPaymentBindingsAlive = destination.rawValue
                }
                state.stackDestinationRequestPayment = destination
                return .none

            case .rateTooltipTapped:
                state.isRateTooltipEnabled = false
                return .none
                
            case .zecKeyboard:
                return .none
            }
        }
    }
}

