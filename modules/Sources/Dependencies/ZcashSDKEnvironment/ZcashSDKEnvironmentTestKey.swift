//
//  ZcashSDKEnvironmentTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit
import XCTestDynamicOverlay

extension ZcashSDKEnvironment: TestDependencyKey {
    public static let testnet = ZcashSDKEnvironment.live(network: ZcashNetworkBuilder.network(for: .testnet))

    public static let testValue = Self(
        latestCheckpoint: 0,
        endpoint: {
            LightWalletEndpoint(
                address: ZcashSDKConstants.endpointTestnetAddress,
                port: ZcashSDKConstants.endpointTestnetPort,
                secure: true,
                streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
            )
        },
        memoCharLimit: MemoBytes.capacity,
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .testnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
        sdkVersion: "0.18.1-beta",
        shieldingThreshold: Zatoshi(100_000),
        tokenName: "TAZ"
    )
}
