//
//  ZCashSDKEnvironment.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.04.2022.
//

import Foundation
import ZcashLightClientKit

// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate enum ZcashSDKConstants {
    static let defaultBlockHeight = 1_629_724
    static let endpointMainnetAddress = "lightwalletd.electriccoin.co"
    static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
    static let endpointPort = 9067
    static let mnemonicWordsMaxCount = 24
    static let requiredTransactionConfirmations = 10
}

struct ZCashSDKEnvironment {
    let defaultBirthday: BlockHeight
    let endpoint: LightWalletEndpoint
    let isMainnet: () -> Bool
    let lightWalletService: LightWalletService
    let mnemonicWordsMaxCount: Int
    let network: ZcashNetwork
    let requiredTransactionConfirmations: Int
}

extension ZCashSDKEnvironment {
    static let mainnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointMainnetAddress, port: ZcashSDKConstants.endpointPort),
        isMainnet: { true },
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointMainnetAddress, port: ZcashSDKConstants.endpointPort)
        ),
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .mainnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations
    )

    static let testnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointTestnetAddress, port: ZcashSDKConstants.endpointPort),
        isMainnet: { false },
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointTestnetAddress, port: ZcashSDKConstants.endpointPort)
        ),
        mnemonicWordsMaxCount: ZcashSDKConstants.mnemonicWordsMaxCount,
        network: ZcashNetworkBuilder.network(for: .testnet),
        requiredTransactionConfirmations: ZcashSDKConstants.requiredTransactionConfirmations
    )
}
