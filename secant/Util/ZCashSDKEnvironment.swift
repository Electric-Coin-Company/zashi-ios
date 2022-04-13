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
    static let endpointMainnetAddress = "lightwalletd.electriccoin.co"
    static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
    static let endpointPort = 9067
    static let defaultBlockHeight = 1_629_724
}

struct ZCashSDKEnvironment {
    let defaultBirthday: BlockHeight
    let endpoint: LightWalletEndpoint
    let lightWalletService: LightWalletService
    let network: ZcashNetwork
    let isMainnet: () -> Bool
}

extension ZCashSDKEnvironment {
    static let mainnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointMainnetAddress, port: ZcashSDKConstants.endpointPort),
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointMainnetAddress, port: ZcashSDKConstants.endpointPort)
        ),
        network: ZcashNetworkBuilder.network(for: .mainnet),
        isMainnet: { true }
    )

    static let testnet = ZCashSDKEnvironment(
        defaultBirthday: BlockHeight(ZcashSDKConstants.defaultBlockHeight),
        endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointTestnetAddress, port: ZcashSDKConstants.endpointPort),
        lightWalletService: LightWalletGRPCService(
            endpoint: LightWalletEndpoint(address: ZcashSDKConstants.endpointTestnetAddress, port: ZcashSDKConstants.endpointPort)
        ),
        network: ZcashNetworkBuilder.network(for: .testnet),
        isMainnet: { false }
    )
}
