//
//  TaxExporterLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-13.
//

import Foundation
import ComposableArchitecture
import UIKit
import Combine

import Generated
import Models
import SDKSynchronizer
import WalletStorage
import MnemonicClient
import DerivationTool
import ZcashSDKEnvironment

extension ShieldingProcessorClient: DependencyKey {
    public static let liveValue: ShieldingProcessorClient = Self.live()
    
    public static func live() -> Self {
        @Dependency(\.derivationTool) var derivationTool
        @Dependency(\.mnemonic) var mnemonic
        @Dependency(\.sdkSynchronizer) var sdkSynchronizer
        @Dependency(\.walletStorage) var walletStorage
        @Dependency(\.zcashSDKEnvironment) var zcashSDKEnvironment

        @Shared(.inMemory(.selectedWalletAccount)) var selectedWalletAccount: WalletAccount? = nil
        
        let subject = CurrentValueSubject<ShieldingProcessorClient.State, Never>(.unknown)
        
        return ShieldingProcessorClient(
            observe: { subject.eraseToAnyPublisher() },
            shieldFunds: {
                subject.send(.requested)
                
                guard let account = selectedWalletAccount, let zip32AccountIndex = account.zip32AccountIndex else {
                    subject.send(.failed("shieldFunds failed, no account available".toZcashError()))
                    return
                }
                
                if account.vendor == .keystone {
                    Task {
                        do {
                            let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)
                            
                            guard let proposal else { throw "shieldFunds with Keystone: nil proposal" }
                            subject.send(.proposal(proposal))
                        } catch {
                            subject.send(.failed(error.toZcashError()))
                        }
                    }
                } else {
                    Task {
                        do {
                            let storedWallet = try walletStorage.exportWallet()
                            let seedBytes = try mnemonic.toSeed(storedWallet.seedPhrase.value())
                            let spendingKey = try derivationTool.deriveSpendingKey(seedBytes, zip32AccountIndex, zcashSDKEnvironment.network.networkType)
                            
                            let proposal = try await sdkSynchronizer.proposeShielding(account.id, zcashSDKEnvironment.shieldingThreshold, .empty, nil)

                            guard let proposal else { throw "shieldFunds nil proposal" }
                            
                            let result = try await sdkSynchronizer.createProposedTransactions(proposal, spendingKey)
                            
                            switch result {
                            case .grpcFailure:
                                subject.send(.grpc)
                            case let .failure(_, code, description):
                                subject.send(.failed("shieldFunds failed \(code) \(description)".toZcashError()))
                            case .partial:
                                break
                            case .success:
                                walletStorage.resetShieldingReminder(WalletAccount.Vendor.zcash.name())
                                subject.send(.succeeded)
                            }
                        } catch {
                            subject.send(.failed(error.toZcashError()))
                        }
                    }
                }
            }
        )
    }
}
