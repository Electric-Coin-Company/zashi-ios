//
//  ZcashSDKEnvironmentLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension ZcashSDKEnvironment: DependencyKey {
    static let liveValue = Self(
        endpoint: LightWalletEndpoint(
            address: ZcashSDKConstants.endpointTestnetAddress,
            port: ZcashSDKConstants.endpointPort,
            secure: true,
            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
        ),
        memoCharLimit: MemoBytes.capacity,
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: TargetConstants.zcashNetwork,
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
        sdkVersion: "0.18.1-beta"
    )
}
