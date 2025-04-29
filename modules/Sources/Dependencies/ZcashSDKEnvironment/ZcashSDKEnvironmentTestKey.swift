//
//  ZcashSDKEnvironmentTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit
import XCTestDynamicOverlay
import UserPreferencesStorage

extension ZcashSDKEnvironment: TestDependencyKey {
    public static let testnet = ZcashSDKEnvironment.live(network: ZcashNetworkBuilder.network(for: .testnet))

    public static let testValue = Self(
        latestCheckpoint: 0,
        endpoint: { defaultEndpoint(for: .testnet) },
        exchangeRateIPRateLimit: 120,
        exchangeRateStaleLimit: 15 * 60,
        memoCharLimit: MemoBytes.capacity,
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .testnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
        sdkVersion: "0.18.1-beta",
        serverConfig: { defaultEndpoint(for: .testnet).serverConfig() },
        servers: [],
        shieldingThreshold: Zatoshi(100_000),
        tokenName: "TAZ"
    )
}
