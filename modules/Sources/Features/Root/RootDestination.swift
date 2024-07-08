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
            case notEnoughFreeSpace
            case onboarding
            case phraseDisplay
            case sandbox
            case startup
            case tabs
            case welcome
        }
        
        public var internalDestination: Destination = .welcome
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
                state.destinationState.destination = destination
                
                return .none

            case .sandbox(.reset):
                state.destinationState.destination = .startup
                return .none

            case .destination(.deeplink(let url)):
                // get the latest synchronizer state
                let synchronizerStatus = sdkSynchronizer.latestState().syncStatus

                // process the deeplink only if app is initialized and synchronizer synced
                guard state.appInitializationState == .initialized && synchronizerStatus == .upToDate else {
                    // TODO: [#370] There are many different states and edge cases we need to handle here
                    // (https://github.com/Electric-Coin-Company/zashi-ios/issues/370)
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
                state.destinationState.destination = .tabs
                //state.tabsState.destination = nil
                return .none

            case let .destination(.deeplinkSend(amount, address, memo)):
                state.destinationState.destination = .tabs
                state.tabsState.selectedTab = .send
                state.tabsState.sendState.amount = amount
                state.tabsState.sendState.address = address.redacted
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
                exchangeRate.refreshExchangeRateUSD()
                return .none

            case .tabs(.settings(.integrations(.flexaTapped))):
                flexaHandler.open()
                return .publisher {
                    flexaHandler.onTransactionRequest()
                        .map(Root.Action.flexaOnTransactionRequest)
                        .receive(on: mainQueue)
                }
                .cancellable(id: CancelFlexaId, cancelInFlight: true)

            case .flexaOnTransactionRequest(let transaction):
                guard let transaction else {
                    return .none
                }
                print("__LD flexa transaction \(transaction)")
                
                return .run { send in
                    do {
                        // get a proposal
                        let recipient = try Recipient(transaction.address, network: zcashSDKEnvironment.network.networkType)
                        let proposal = try await sdkSynchronizer.proposeTransfer(0, recipient, transaction.amount, nil)
                        
                        // make the actual send
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let network = zcashSDKEnvironment.network.networkType
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, 0, network)

                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                        
                        switch result {
                        case .failure(let txIds):
                            print("__LD failure \(txIds)")
//                            await send(.sendFailed("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case let .partial(txIds: txIds, statuses: statuses):
                            print("__LD partial \(txIds)")
//                            await send(.sendPartial(txIds, statuses))
                        case .success(let txIds):
                            print("__LD success \(txIds)")
//                            await send(.sendDone)
                            if let txId = txIds.first {
                                print("__LD all good! \(txId)")
                                flexaHandler.transactionSent(transaction.commerceSessionId, txId)
                            }
                            //Flexa.transactionSent(commerceSessionId: transaction.commerceSessionId, signature: signature)
                        }
//                        await send(.proposal(proposal))
//                        await send(.sendConfirmationRequired)
                    } catch {
                        print(error)
                        print(error)
//                        await send(.sendFailed(error.toZcashError()))
                    }
                }
                
            case .tabs, .initialization, .onboarding, .sandbox, .updateStateAfterConfigUpdate, .alert, .phraseDisplay, .synchronizerStateChanged,
                    .welcome, .binding, .nukeWalletFailed, .nukeWalletSucceeded, .debug, .walletConfigLoaded, .exportLogs, .confirmationDialog,
                    .notEnoughFreeSpace, .serverSetup, .serverSetupBindingUpdated, .batteryStateChanged, .cancelAllRunningEffects:
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
