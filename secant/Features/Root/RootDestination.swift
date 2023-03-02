//
//  RootDestination.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.12.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

/// In this file is a collection of helpers that control all state and action related operations
/// for the `RootReducer` with a connection to the UI navigation.
extension RootReducer {
    struct DestinationState: Equatable {
        enum Destination: Equatable {
            case home
            case onboarding
            case phraseDisplay
            case phraseValidation
            case sandbox
            case startup
            case welcome
        }
        
        @BindingState var alert: AlertState<RootReducer.Action>?
        var internalDestination: Destination = .welcome
        var previousDestination: Destination?

        var destination: Destination {
            get { internalDestination }
            set {
                previousDestination = internalDestination
                internalDestination = newValue
            }
        }
    }
    
    enum DestinationAction: Equatable {
        case deeplink(URL)
        case deeplinkHome
        case deeplinkSend(Zatoshi, String, String)
        case deeplinkFailed(URL, String)
        case dismissAlert
        case updateDestination(RootReducer.DestinationState.Destination)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func destinationReduce() -> Reduce<RootReducer.State, RootReducer.Action> {
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
                let synchronizerStatus = sdkSynchronizer.stateChanged.value

                // process the deeplink only if app is initialized and synchronizer synced
                guard state.appInitializationState == .initialized && synchronizerStatus == .synced else {
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
                        await send(.destination(.deeplinkFailed(url, error.localizedDescription)))
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

            case let .destination(.deeplinkFailed(url, errorDescription)):
                // TODO: [#221] Handle error more properly (https://github.com/zcash/secant-ios-wallet/issues/221)
                state.destinationState.alert = AlertState(
                    title: TextState("Failed to process deeplink."),
                    message: TextState("Deeplink: \(url))\nError: \(errorDescription)"),
                    dismissButton: .default(
                        TextState("Ok"),
                        action: .send(.destination(.dismissAlert))
                    )
                )
                return .none

            case .home(.walletEvents(.replyTo(let address))):
                guard let url = URL(string: "zcash:\(address)") else {
                    return .none
                }
                return EffectTask(value: .destination(.deeplink(url)))

            case .destination(.dismissAlert):
                state.destinationState.alert = nil
                return .none
                
            case .home, .initialization, .onboarding, .phraseDisplay, .phraseValidation,
                .sandbox, .welcome, .binding, .nukeWalletFailed, .nukeWalletSucceeded, .debug, .walletConfigLoaded, .dismissAlert:
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
        let deeplink = try deeplink.resolveDeeplinkURL(url, derivationTool)
        
        switch deeplink {
        case .home:
            return .destination(.deeplinkHome)
        case let .send(amount, address, memo):
            return .destination(.deeplinkSend(Zatoshi(amount), address, memo))
        }
    }
}

extension RootViewStore {
    func goToDestination(_ destination: RootReducer.DestinationState.Destination) {
        send(.destination(.updateDestination(destination)))
    }
    
    func goToDeeplink(_ deeplink: URL) {
        send(.destination(.deeplink(deeplink)))
    }
}

// MARK: Placeholders

extension RootReducer.DestinationState {
    static var placeholder: Self {
        .init()
    }
}
