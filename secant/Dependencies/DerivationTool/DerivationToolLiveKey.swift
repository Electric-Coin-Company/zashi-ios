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
        
    static func live() -> Self {
        let derivationTool = DerivationTool(networkType: TargetConstants.zcashNetwork.networkType)
        return Self(
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
                do {
                    _ = try Recipient(address, network: TargetConstants.zcashNetwork.networkType)
                    return true
                } catch {
                    return false
                }
            }
        )
    }
}
