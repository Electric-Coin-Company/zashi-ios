//
//  ShieldingProcessorStore.swift
//  modules
//
//  Created by Lukáš Korba on 08.04.2025.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit
import DerivationTool
import MnemonicClient
import Utils
import Generated
import WalletStorage
import SDKSynchronizer
import Models
import ZcashSDKEnvironment

@Reducer
public struct ShieldingProcessor {
    @ObservableState
    public struct State: Equatable {
        public var isShieldingFunds = false
        @Shared(.inMemory(.selectedWalletAccount)) public var selectedWalletAccount: WalletAccount? = nil

        public init() { }
    }

    @CasePathable
    public enum Action: Equatable {
        case proposalReadyForShieldingWithKeystone(Proposal)
        case shieldFunds
        case shieldFundsFailure(ZcashError)
        case shieldFundsSuccess
        case shieldFundsWithKeystone
    }

    @Dependency(\.derivationTool) var derivationTool
    @Dependency(\.mnemonic) var mnemonic
    @Dependency(\.sdkSynchronizer) var sdkSynchronizer
    @Dependency(\.walletStorage) var walletStorage
    @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

    public init() { }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shieldFunds:
                guard let account = state.selectedWalletAccount, let zip32AccountIndex = account.zip32AccountIndex else {
                    return .none
                }
                if account.vendor == .keystone {
                    return .send(.shieldFundsWithKeystone)
                }
                // Regular path only for Zashi account
                state.isShieldingFunds = true
                return .run { send in
                    do {
                        let storedWallet = try walletStorage.exportWallet()
                        let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                        let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, zcashSDKEnvironment.network.networkType)

                        let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)
                        
                        guard let proposal else { throw "sdkSynchronizer.proposeShielding" }
                        
                        let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)

                        switch result {
                        case .grpcFailure:
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case .failure:
                            await send(.shieldFundsFailure("sdkSynchronizer.createProposedTransactions".toZcashError()))
                        case .partial:
                            break
                        case .success:
                            await send(.shieldFundsSuccess)
                        }
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }
                
            case .shieldFundsWithKeystone:
                guard let account = state.selectedWalletAccount else {
                    return .none
                }
                return .run { send in
                    do {
                        let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)
                        
                        guard let proposal else { throw "sdkSynchronizer.proposeShielding" }
                        await send(.proposalReadyForShieldingWithKeystone(proposal))
                    } catch {
                        await send(.shieldFundsFailure(error.toZcashError()))
                    }
                }
                
            case .proposalReadyForShieldingWithKeystone:
                return .none

            case .shieldFundsFailure:
                state.isShieldingFunds = false
                return .none

            case .shieldFundsSuccess:
                state.isShieldingFunds = false
                return .none
            }
        }
    }
}

// MARK: Alerts

extension AlertState where Action == ShieldingProcessor.Action {
    public static func shieldFundsFailure(_ error: ZcashError) -> AlertState {
        AlertState {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.title)
        } message: {
            TextState(L10n.Balances.Alert.ShieldFunds.Failure.message(error.detailedMessage))
        }
    }
}
