//
//  ZCashSDKEnvironment.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.04.2022.
//

import Foundation
import ZcashLightClientKit
import ComposableArchitecture

// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate enum ZcashSDKConstants {
    static let defaultBlockHeight = 1_629_724
    static let endpointMainnetAddress = "lightwalletd.electriccoin.co"
    static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
    static let endpointPort = 9067
    static let mnemonicWordsMaxCount = 24
    static let requiredTransactionConfirmations = 10
    static let streamingCallTimeoutInMillis = Int64(10 * 60 * 60 * 1000) // ten hours
}

struct ZCashSDKEnvironment {
    let defaultBirthday: BlockHeight
    let endpoint: LightWalletEndpoint
    let isMainnet: () -> Bool
    let lightWalletService: LightWalletService
    let memoCharLimit: Int
    let mnemonicWordsMaxCount: Int
    let network: ZcashNetwork
    let requiredTransactionConfirmations: Int
    let sdkVersion: String
}

extension ZCashSDKEnvironment {
    static let mainnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(
            address: ZcashSDKConstants.endpointMainnetAddress,
            port: ZcashSDKConstants.endpointPort,
            secure: true,
            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
        ),
        isMainnet: { true },
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(
                address: ZcashSDKConstants.endpointMainnetAddress,
                port: ZcashSDKConstants.endpointPort,
                secure: true,
                streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
            )
        ),
        memoCharLimit: 512,
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .mainnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations,
        sdkVersion: "0.16.5-beta"
    )

    static let testnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(
            address: ZcashSDKConstants.endpointTestnetAddress,
            port: ZcashSDKConstants.endpointPort,
            secure: true,
            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
        ),
        isMainnet: { false },
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
        sdkVersion: "0.16.5-beta"
    )
}

private enum ZCashSDKEnvironmentKey: DependencyKey {
    static let liveValue = ZCashSDKEnvironment.mainnet
    static let testValue = ZCashSDKEnvironment.testnet
}

extension DependencyValues {
    var zcashSDKEnvironment: ZCashSDKEnvironment {
        get { self[ZCashSDKEnvironmentKey.self] }
        set { self[ZCashSDKEnvironmentKey.self] = newValue }
    }
}
