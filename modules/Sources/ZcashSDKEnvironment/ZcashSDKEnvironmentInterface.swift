//
//  ZcashSDKEnvironmentInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var zcashSDKEnvironment: ZcashSDKEnvironment {
        get { self[ZcashSDKEnvironment.self] }
        set { self[ZcashSDKEnvironment.self] = newValue }
    }
}

extension ZcashSDKEnvironment {
    public enum ZcashSDKConstants {
        static let endpointMainnetAddress = "lightwalletd.electriccoin.co"
        static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
        static let endpointPort = 9067
        static let mnemonicWordsMaxCount = 24
        static let requiredTransactionConfirmations = 10
        static let streamingCallTimeoutInMillis = Int64(10 * 60 * 60 * 1000) // ten hours
    }

    public static func endpoint(for network: ZcashNetwork) -> String {
        switch network.networkType {
        case .testnet:
            return ZcashSDKConstants.endpointTestnetAddress
        case .mainnet:
            return ZcashSDKConstants.endpointMainnetAddress
        }
    }
}

public struct ZcashSDKEnvironment {
    public var latestCheckpoint: (ZcashNetwork) -> BlockHeight //{ BlockHeight.ofLatestCheckpoint(network: network()) }
    public let endpoint: (ZcashNetwork) -> LightWalletEndpoint
    //public var isMainnet: Bool { network().networkType == .mainnet }
    public let memoCharLimit: Int
    public let mnemonicWordsMaxCount: Int
    //public let network: () -> ZcashNetwork
    public let requiredTransactionConfirmations: Int
    public let sdkVersion: String
}
