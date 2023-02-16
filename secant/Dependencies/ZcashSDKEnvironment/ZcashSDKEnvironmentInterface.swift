//
//  ZcashSDKEnvironmentInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    var zcashSDKEnvironment: ZcashSDKEnvironment {
        get { self[ZcashSDKEnvironment.self] }
        set { self[ZcashSDKEnvironment.self] = newValue }
    }
}

extension ZcashSDKEnvironment {
    enum ZcashSDKConstants {
        static let endpointMainnetAddress = "lightwalletd.electriccoin.co"
        static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
        static let endpointPort = 9067
        static let mnemonicWordsMaxCount = 24
        static let requiredTransactionConfirmations = 10
        static let streamingCallTimeoutInMillis = Int64(10 * 60 * 60 * 1000) // ten hours
    }
}

struct ZcashSDKEnvironment {
    var latestCheckpoint: BlockHeight { BlockHeight.ofLatestCheckpoint(network: self.network) }
    let endpoint: LightWalletEndpoint
    var isMainnet: Bool { network.networkType == .mainnet }
    let memoCharLimit: Int
    let mnemonicWordsMaxCount: Int
    let network: ZcashNetwork
    let requiredTransactionConfirmations: Int
    let sdkVersion: String
}
