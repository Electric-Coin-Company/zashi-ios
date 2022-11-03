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
            deriveUnifiedViewingKeyFromSpendingKey: { spendingKey in
                try derivationTool.deriveUnifiedFullViewingKey(from: spendingKey)
            },
            deriveSpendingKey: { seed, accountIndex in
                try derivationTool.deriveUnifiedSpendingKey(seed: seed, accountIndex: accountIndex)
            },
            isValidTransparentAddress: { tAddress in
                derivationTool.isValidTransparentAddress(tAddress)
            },
            isValidSaplingAddress: { zAddress in
                derivationTool.isValidSaplingAddress(zAddress)
            },
            isValidZcashAddress: { address in
                derivationTool.isValidTransparentAddress(address) ? true :
                derivationTool.isValidSaplingAddress(address) ? true : false
            }
        )
    }
}
