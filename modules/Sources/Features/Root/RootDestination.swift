//
//  RootDestination.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.12.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Deeplink
import DerivationTool

import SwiftUI

/// In this file is a collection of helpers that control all state and action related operations
/// for the `Root` with a connection to the UI navigation.
extension Root {
    public struct DestinationState: Equatable {
        public enum Destination: Equatable {
            case deeplinkWarning
            case notEnoughFreeSpace
            case onboarding
            case phraseDisplay
            case sandbox
            case startup
            case tabs
            case welcome
        }
        
        public var internalDestination: Destination = .welcome
        public var isDeeplinkWarningRequest = false
        public var preDeeplinkWarningDestination: Destination? = nil
        public var preNotEnoughFreeSpaceDestination: Destination?
        public var previousDestination: Destination?

        public var destination: Destination {
            get { internalDestination }
            set {
                previousDestination = internalDestination
                internalDestination = newValue
            }
        }
    }
    
    public enum DestinationAction: Equatable {
        case deeplink(URL)
        case deeplinkHome
        case deeplinkSend(Zatoshi, String, String)
        case deeplinkFailed(URL, ZcashError)
        case updateDestination(Root.DestinationState.Destination)
        case serverSwitch
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func destinationReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case let .destination(.updateDestination(destination)):
                if state.destinationState.isDeeplinkWarningRequest {
                    state.destinationState.preDeeplinkWarningDestination = state.destinationState.destination == .welcome ? destination : state.destinationState.destination
                    state.destinationState.isDeeplinkWarningRequest = false
                    state.destinationState.destination = .deeplinkWarning
                } else {
                    state.destinationState.destination = destination
                }
                return .none

            case .sandbox(.reset):
                state.destinationState.destination = .startup
                return .none

            case .deeplinkWarning(.gotItTapped):
//                let destination = state.destinationState.previousDestination ?? state.destinationState.destination
//                return .send(.destination(.updateDestination(destination)))
                if let preDeeplink = state.destinationState.preDeeplinkWarningDestination, preDeeplink != .tabs {
                    return .send(.destination(.updateDestination(preDeeplink)))
                } else {
                    state.tabsState.selectedTab = .send
                    state.tabsState.sendState.transactionAddressInputState.doesButtonPulse = true
                    state.tabsState.destination = nil
                    state.tabsState.settingsState.destination = nil
                    state.tabsState.settingsState.advancedSettingsState.destination = nil
                    state.tabsState.sendState.destination = nil
                    return .send(.destination(.updateDestination(.tabs)))
                }

            case .destination(.deeplink(let url)):
                if let _ = uriParser.checkRP(url.absoluteString) {
                    // The deeplink is some zip321, we ignore it and let users know in a warning screen
                    state.destinationState.isDeeplinkWarningRequest = true
                }
                return .none

            case .destination(.deeplinkHome):
                state.destinationState.destination = .tabs
                //state.tabsState.destination = nil
                return .none

            case let .destination(.deeplinkSend(amount, address, memo)):
                state.destinationState.destination = .tabs
                state.tabsState.selectedTab = .send
                state.tabsState.sendState.amount = amount
                state.tabsState.sendState.address = address
                state.tabsState.sendState.memoState.text = memo.redacted
                return .none

            case let .destination(.deeplinkFailed(url, error)):
                state.alert = AlertState.failedToProcessDeeplink(url, error)
                return .none

            case .destination(.serverSwitch):
                state.serverSetupViewBinding = true
                return .none

            case .splashRemovalRequested:
                return .run { send in
                    try await mainQueue.sleep(for: .seconds(0.01))
                    await send(.splashFinished)
                }
            
            case .splashFinished:
                state.splashAppeared = true
                return .none

            case .tabs, .initialization, .onboarding, .sandbox, .updateStateAfterConfigUpdate, .alert, .phraseDisplay, .synchronizerStateChanged,
                    .welcome, .binding, .nukeWalletFailed, .nukeWalletSucceeded, .debug, .walletConfigLoaded, .exportLogs, .confirmationDialog,
                    .notEnoughFreeSpace, .serverSetup, .serverSetupBindingUpdated, .batteryStateChanged, .cancelAllRunningEffects, .addressBookBinding, .addressBook:
                return .none
            }
        }
    }
}

private extension Root {
    func process(
        url: URL,
        deeplink: DeeplinkClient,
        derivationTool: DerivationToolClient
    ) async throws -> Root.Action {
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment
        let deeplink = try deeplink.resolveDeeplinkURL(url, zcashSDKEnvironment.network.networkType, derivationTool)
        
        switch deeplink {
        case .home:
            return .destination(.deeplinkHome)
        case let .send(amount, address, memo):
            return .destination(.deeplinkSend(Zatoshi(Int64(amount)), address, memo))
        }
    }
}

extension StoreOf<Root> {
    public func goToDestination(_ destination: Root.DestinationState.Destination) {
        send(.destination(.updateDestination(destination)))
    }
    
    public func goToDeeplink(_ deeplink: URL) {
        send(.destination(.deeplink(deeplink)))
    }
}

// MARK: Placeholders

extension Root.DestinationState {
    public static var initial: Self {
        .init()
    }
}
