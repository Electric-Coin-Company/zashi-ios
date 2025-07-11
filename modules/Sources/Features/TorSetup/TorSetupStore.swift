//
//  TorSetupStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-07-10.
//

import ComposableArchitecture
import ZcashLightClientKit

import Generated
import ExchangeRate
import WalletStorage
import Models

@Reducer
public struct TorSetup {
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
                case .optIn: return L10n.TorSetup.enableDesc
                case .optOut: return L10n.TorSetup.disableDesc
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
            case stayPrivate
            
            public func title() -> String {
                switch self {
                case .ipAddress: return L10n.TorSetup.Option1.title
                case .stayPrivate: return L10n.TorSetup.Option2.title
                }
            }

            public func subtitle() -> String {
                switch self {
                case .ipAddress: return L10n.TorSetup.Option1.desc
                case .stayPrivate: return L10n.TorSetup.Option2.desc
                }
            }

            public func icon() -> ImageAsset {
                switch self {
                case .ipAddress: return Asset.Assets.Icons.shieldZap
                case .stayPrivate: return Asset.Assets.Icons.lockLocked
                }
            }
        }

        public var activeSettingsOption: SettingsOptions?
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
        case binding(BindingAction<TorSetup.State>)
        case enableTapped
        case onAppear
        case saveChangesTapped
        case settingsOptionChanged(State.SettingsOptions)
        case settingsOptionTapped(State.SettingsOptions)
        case skipTapped
    }

    @Dependency(\.walletStorage) var walletStorage

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let torEnabled = walletStorage.exportTorSetupFlag(), torEnabled {
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
                try? walletStorage.importTorSetupFlag(true)
                return .run { _ in
                    await LwdConnectionOverTorFlag.shared.update(true)
                }

            case .settingsOptionChanged:
                return .none

            case .settingsOptionTapped(let newOption):
                state.currentSettingsOption = newOption
                return .none
                
            case .saveChangesTapped:
                let newFlag = state.currentSettingsOption == .optIn
                try? walletStorage.importTorSetupFlag(newFlag)
                state.activeSettingsOption = state.currentSettingsOption
                let currentSettingsOption = state.currentSettingsOption
                return .run { send in
                    await send(.settingsOptionChanged(currentSettingsOption))
                    await LwdConnectionOverTorFlag.shared.update(newFlag)
                }

            case .skipTapped:
                try? walletStorage.importTorSetupFlag(false)
                return .run { _ in
                    await LwdConnectionOverTorFlag.shared.update(false)
                }
            }
        }
    }
}
