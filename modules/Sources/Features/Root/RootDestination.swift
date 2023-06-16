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

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the UI navigation.
extension RootReducer {
    public struct DestinationState: Equatable {
        public enum Destination: Equatable {
            case home
            case onboarding
            case phraseDisplay
            case phraseValidation
            case sandbox
            case startup
            case welcome
        }
        
        public var internalDestination: Destination = .welcome
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
        case updateDestination(RootReducer.DestinationState.Destination)
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func destinationReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
        Reduce { state, action in
            switch action {
            case let .destination(.updateDestination(destination)):
                state.destinationState.destination = destination

            case .sandbox(.reset):
                state.destinationState.destination = .startup

            case .phraseValidation(.proceedToHome):
                state.destinationState.destination = .home

            case .phraseValidation(.displayBackedUpPhrase):
                state.destinationState.destination = .phraseDisplay

            case .phraseDisplay(.finishedPressed):
                // user is still supposed to do the backup phrase validation test
                if (state.destinationState.previousDestination == .welcome
                || state.destinationState.previousDestination == .onboarding
                || state.destinationState.previousDestination == .startup)
                && state.walletConfig.isEnabled(.testBackupPhraseFlow) {
                    state.destinationState.destination = .phraseValidation
                }
                // user wanted to see the backup phrase once again (at validation finished screen)
                if state.destinationState.previousDestination == .phraseValidation
                || !state.walletConfig.isEnabled(.testBackupPhraseFlow) {
                    state.destinationState.destination = .home
                }

            case .destination(.deeplink(let url)):
                // get the latest synchronizer state
                let synchronizerStatus = sdkSynchronizer.latestState().syncStatus

                // process the deeplink only if app is initialized and synchronizer synced
                guard state.appInitializationState == .initialized && synchronizerStatus == .upToDate else {
                    // TODO: [#370] There are many different states and edge cases we need to handle here
                    // (https://github.com/zcash/secant-ios-wallet/issues/370)
                    return .none
                }
                return .run { send in
                    do {
                        await send(
                            try await process(
                                url: url,
                                deeplink: deeplink,
                                derivationTool: derivationTool
                            )
                        )
                    } catch {
                        await send(.destination(.deeplinkFailed(url, error.toZcashError())))
                    }
                }

            case .destination(.deeplinkHome):
                state.destinationState.destination = .home
                state.homeState.destination = nil
                return .none

            case let .destination(.deeplinkSend(amount, address, memo)):
                state.destinationState.destination = .home
                state.homeState.destination = .send
                state.homeState.sendState.amount = amount
                state.homeState.sendState.address = address
                state.homeState.sendState.memoState.text = memo.redacted
                return .none

            case let .destination(.deeplinkFailed(url, error)):
                state.alert = AlertState.failedToProcessDeeplink(url, error)
                return .none

            case .home(.walletEvents(.replyTo(let address))):
                guard let url = URL(string: "zcash:\(address)") else {
                    return .none
                }
                return EffectTask(value: .destination(.deeplink(url)))

            case .home, .initialization, .onboarding, .phraseDisplay, .phraseValidation, .sandbox, .updateStateAfterConfigUpdate, .alert,
                .welcome, .binding, .nukeWalletFailed, .nukeWalletSucceeded, .debug, .walletConfigLoaded, .exportLogs:
                return .none
            }
            
            return .none
        }
    }
}

private extension RootReducer {
    func process(
        url: URL,
        deeplink: DeeplinkClient,
        derivationTool: DerivationToolClient
    ) async throws -> RootReducer.Action {
        let deeplink = try deeplink.resolveDeeplinkURL(url, zcashNetwork.networkType, derivationTool)
        
        switch deeplink {
        case .home:
            return .destination(.deeplinkHome)
        case let .send(amount, address, memo):
            return .destination(.deeplinkSend(Zatoshi(Int64(amount)), address, memo))
        }
    }
}

extension RootViewStore {
    public func goToDestination(_ destination: RootReducer.DestinationState.Destination) {
        send(.destination(.updateDestination(destination)))
    }
    
    public func goToDeeplink(_ deeplink: URL) {
        send(.destination(.deeplink(deeplink)))
    }
}

// MARK: Placeholders

extension RootReducer.DestinationState {
    public static var placeholder: Self {
        .init()
    }
}
