//
//  DerivationToolLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DerivationToolClient: DependencyKey {
    public static let liveValue = DerivationToolClient.live()
        
    public static func live() -> Self {
        Self(
            deriveSpendingKey: { seed, accountIndex, networkType in
                try DerivationTool(networkType: networkType).deriveUnifiedSpendingKey(seed: seed, accountIndex: accountIndex)
            },
            deriveUnifiedFullViewingKey: { spendingKey, networkType in
                try DerivationTool(networkType: networkType).deriveUnifiedFullViewingKey(from: spendingKey)
            },
            isUnifiedAddress: { address, networkType in
                do {
                    if case .unified = try Recipient(address, network: networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isSaplingAddress: { address, networkType in
                do {
                    if case .sapling = try Recipient(address, network: networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isTransparentAddress: { address, networkType in
                do {
                    if case .transparent = try Recipient(address, network: networkType) {
                        return true
                    } else {
                        return false
                    }
                } catch {
                    return false
                }
            },
            isZcashAddress: { address, networkType in
                do {
                    _ = try Recipient(address, network: networkType)
                    return true
                } catch {
                    return false
                }
            }
        )
    }
}
