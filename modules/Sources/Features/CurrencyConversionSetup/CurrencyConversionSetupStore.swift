//
//  CurrencyConversionSetupStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-12-2024
//

import ComposableArchitecture

import Generated
import ExchangeRate
import UserPreferencesStorage
import Models

@Reducer
public struct CurrencyConversionSetup {
    @ObservableState
    public struct State: Equatable {
        public enum SettingsOptions: CaseIterable {
            case optIn
            case optOut
            
            public func title() -> String {
                switch self {
                case .optIn: return L10n.CurrencyConversion.enable
                case .optOut: return L10n.CurrencyConversion.learnMoreOptionDisable
                }
            }

            public func subtitle() -> String {
                switch self {
                case .optIn: return L10n.CurrencyConversion.learnMoreOptionEnableDesc
                case .optOut: return L10n.CurrencyConversion.learnMoreOptionDisableDesc
                }
            }
            
            public func icon() -> ImageAsset {
                switch self {
                case .optIn: return Asset.Assets.check
                case .optOut: return Asset.Assets.buttonCloseX
                }
            }
        }
        
        public enum LearnMoreOptions: CaseIterable {
            case ipAddress
            case refresh
            
            public func title() -> String {
                switch self {
                case .ipAddress: return L10n.CurrencyConversion.ipTitle
                case .refresh: return L10n.CurrencyConversion.refresh
                }
            }

            public func subtitle() -> String {
                switch self {
                case .ipAddress: return L10n.CurrencyConversion.ipDesc
                case .refresh: return L10n.CurrencyConversion.refreshDesc
                }
            }

            public func icon() -> ImageAsset {
                switch self {
                case .ipAddress: return Asset.Assets.shieldTick
                case .refresh: return Asset.Assets.refreshCCW
                }
            }
        }

        public var activeSettingsOption: SettingsOptions?
        @Shared(.inMemory(.exchangeRate)) public var currencyConversion: CurrencyConversion? = nil
        public var currentSettingsOption = SettingsOptions.optOut
        public var isSettingsView: Bool = false

        public var isSaveButtonDisabled: Bool {
            currentSettingsOption == activeSettingsOption
        }
        
        public init(
            activeSettingsOption: SettingsOptions? = nil,
            currentSettingsOption: SettingsOptions = .optOut,
            isSettingsView: Bool = false
        ) {
            self.activeSettingsOption = activeSettingsOption
            self.currentSettingsOption = currentSettingsOption
            self.isSettingsView = isSettingsView
        }
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<CurrencyConversionSetup.State>)
        case enableTapped
        case onAppear
        case saveChangesTapped
        case settingsOptionChanged(State.SettingsOptions)
        case settingsOptionTapped(State.SettingsOptions)
        case skipTapped
    }

    @Dependency(\.exchangeRate) var exchangeRate
    @Dependency(\.userStoredPreferences) var userStoredPreferences

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let automatic = userStoredPreferences.exchangeRate()?.automatic, automatic {
                    state.activeSettingsOption = .optIn
                    state.currentSettingsOption = .optIn
                } else {
                    state.activeSettingsOption = .optOut
                    state.currentSettingsOption = .optOut
                }
                return .none
                
            case .binding:
                return .none
                
            case .enableTapped:
                try? userStoredPreferences.setExchangeRate(.init(manual: true, automatic: true))
                exchangeRate.refreshExchangeRateUSD()
                return .none

            case .settingsOptionChanged(let option):
                if option == .optOut {
                    state.currencyConversion = nil
                }
                return .none

            case .settingsOptionTapped(let newOption):
                state.currentSettingsOption = newOption
                return .none
                
            case .saveChangesTapped:
                try? userStoredPreferences.setExchangeRate(UserPreferencesStorage.ExchangeRate(manual: true, automatic: state.currentSettingsOption == .optIn))
                exchangeRate.refreshExchangeRateUSD()
                state.activeSettingsOption = state.currentSettingsOption
                return .send(.settingsOptionChanged(state.currentSettingsOption))

            case .skipTapped:
                try? userStoredPreferences.setExchangeRate(.init(manual: false, automatic: false))
                return .none
            }
        }
    }
}
