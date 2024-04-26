//
//  ZcashSDKEnvironmentLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension ZcashSDKEnvironment {
    public static func live(network: ZcashNetwork) -> Self {
        Self(
            latestCheckpoint: BlockHeight.ofLatestCheckpoint(network: network),
            endpoint: {
                // In case of mainnet network we may have stored server as a user action in advanced settings
                if network.networkType == .mainnet {
                    @Dependency(\.userDefaults) var userDefaults
                    
                    let udKey = ZcashSDKEnvironment.Servers.Constants.udServerKey
                    
                    if let storedServerRaw = userDefaults.objectForKey(udKey) as? String,
                       let storedServer = ZcashSDKEnvironment.Servers(rawValue: storedServerRaw) {
                        if let endpoint = storedServer.lightWalletEndpoint(userDefaults) {
                            // Some endpoint is set by a user so we initialize the SDK with this one
                            return endpoint
                        } else {
                            // Initalization of LightWalletEndpoint failed, fallback to hardcoded one,
                            // setting the mainnet key to the storage to reflect that
                            userDefaults.setValue(ZcashSDKEnvironment.Servers.globalZR.rawValue, udKey)
                        }
                    }
                }
                
                // Hardcoded endpoint
                return LightWalletEndpoint(
                    address: Self.endpointString(for: network),
                    port: network.networkType == .testnet ? ZcashSDKConstants.endpointTestnetPort : ZcashSDKConstants.endpointMainnetPort,
                    secure: true,
                    streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
                )
            },
            memoCharLimit: MemoBytes.capacity,
            mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
            network: network,
            requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
            sdkVersion: "0.18.1-beta",
            shieldingThreshold: Zatoshi(100_000),
            tokenName: network.networkType == .testnet ? "TAZ" : "ZEC"
        )
    }
}
