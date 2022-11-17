//
//  DerivationToolLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DerivationToolClient: DependencyKey {
    static let liveValue = DerivationToolClient.live()
        
    static func live(derivationTool: DerivationTool = DerivationTool(networkType: .testnet)) -> Self {
        Self(
            deriveViewingKeys: { seed, numberOfAccounts in
                try derivationTool.deriveViewingKeys(seed: seed, numberOfAccounts: numberOfAccounts)
            },
            deriveViewingKey: { spendingKey in
                try derivationTool.deriveViewingKey(spendingKey: spendingKey)
            },
            deriveSpendingKeys: { seed, numberOfAccounts in
                try derivationTool.deriveSpendingKeys(seed: seed, numberOfAccounts: numberOfAccounts)
            },
            deriveShieldedAddress: { seed, accountIndex in
                try derivationTool.deriveShieldedAddress(seed: seed, accountIndex: accountIndex)
            },
            deriveShieldedAddressFromViewingKey: { viewingKey in
                try derivationTool.deriveShieldedAddress(viewingKey: viewingKey)
            },
            deriveTransparentAddress: { seed, account, index in
                try derivationTool.deriveTransparentAddress(seed: seed, account: account, index: index)
            },
            deriveUnifiedViewingKeysFromSeed: { seed, numberOfAccounts in
                try derivationTool.deriveUnifiedViewingKeysFromSeed(seed, numberOfAccounts: numberOfAccounts)
            },
            deriveUnifiedAddressFromUnifiedViewingKey: { uvk in
                try derivationTool.deriveUnifiedAddressFromUnifiedViewingKey(uvk)
            },
            deriveTransparentAddressFromPublicKey: { pubkey in
                try derivationTool.deriveTransparentAddressFromPublicKey(pubkey)
            },
            deriveTransparentPrivateKey: { seed, account, index in
                try derivationTool.deriveTransparentPrivateKey(seed: seed, account: account, index: index)
            },
            deriveTransparentAddressFromPrivateKey: { tsk in
                try derivationTool.deriveTransparentAddressFromPrivateKey(tsk)
            },
            isValidExtendedViewingKey: { extvk in
                try derivationTool.isValidExtendedViewingKey(extvk)
            },
            isValidTransparentAddress: { tAddress in
                try derivationTool.isValidTransparentAddress(tAddress)
            },
            isValidShieldedAddress: { zAddress in
                try derivationTool.isValidShieldedAddress(zAddress)
            },
            isValidZcashAddress: { address in
                try derivationTool.isValidTransparentAddress(address) ? true :
                try derivationTool.isValidShieldedAddress(address) ? true : false
            }
        )
    }
}
