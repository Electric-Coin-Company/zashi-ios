//
//  ZcashSDKEnvironmentLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension ZcashSDKEnvironment: DependencyKey {
    static let mainnet = ZcashSDKEnvironment.liveValue
    
    static let liveValue = Self(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(
            address: ZcashSDKConstants.endpointTestnetAddress,
            port: ZcashSDKConstants.endpointPort,
            secure: true,
            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
        ),
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(
                address: ZcashSDKConstants.endpointTestnetAddress,
                port: ZcashSDKConstants.endpointPort,
                secure: true,
                streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
            )
        ),
        memoCharLimit: 512,
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .testnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
        sdkVersion: "0.17.0-beta"
    )
}
