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
            deriveUnifiedFullViewingKey: { spendingKey in
                try derivationTool.deriveUnifiedFullViewingKey(from: spendingKey)
            },
            isUnifiedAddress: { address in
                do {
                    if case .unified = try Recipient(address, network: TargetConstants.zcashNetwork.networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isSaplingAddress: { address in
                do {
                    if case .sapling = try Recipient(address, network: TargetConstants.zcashNetwork.networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isTransparentAddress: { address in
                do {
                    if case .transparent = try Recipient(address, network: TargetConstants.zcashNetwork.networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isZcashAddress: { address in
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
