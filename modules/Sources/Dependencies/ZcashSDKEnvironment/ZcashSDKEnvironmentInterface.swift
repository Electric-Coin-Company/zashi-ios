//
//  ZcashSDKEnvironmentInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

import Generated
import UserPreferencesStorage

extension DependencyValues {
    public var zcashSDKEnvironment: ZcashSDKEnvironment {
        get { self[ZcashSDKEnvironment.self] }
        set { self[ZcashSDKEnvironment.self] = newValue }
    }
}

extension ZcashSDKEnvironment {
    public enum ZcashSDKConstants {
        static let endpointMainnetAddress = "zec.rocks"
        static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
        static let endpointMainnetPort = 443
        static let endpointTestnetPort = 9067
        static let mnemonicWordsMaxCount = 24
        static let requiredTransactionConfirmations = 10
        public static let streamingCallTimeoutInMillis = Int64(10 * 60 * 60 * 1000) // ten hours
    }
    
    public enum Server: Equatable, Hashable {
        case custom
        case `default`
        case hardcoded(String)
        
        public func name(for network: NetworkType) -> String {
            var value = value(for: network)
            
            if case .default = self {
                value = L10n.ServerSetup.default(value)
            }
            
            return value
        }
        
        public func value(for network: NetworkType) -> String {
            switch self {
            case .custom:
                return L10n.ServerSetup.custom
            case .default:
                return defaultEndpoint(for: network).server()
            case .hardcoded(let value):
                return value
            }
        }
    }

    public static func servers(for network: NetworkType) -> [Server] {
        var servers = [Server.default]

        if network == .mainnet {
            servers.append(
                contentsOf: [
                    Server.custom,
                    Server.hardcoded("na.zec.rocks:443"),
                    Server.hardcoded("sa.zec.rocks:443"),
                    Server.hardcoded("eu.zec.rocks:443"),
                    Server.hardcoded("ap.zec.rocks:443"),
                    Server.hardcoded("lwd1.zcash-infra.com:9067"),
                    Server.hardcoded("lwd2.zcash-infra.com:9067"),
                    Server.hardcoded("lwd3.zcash-infra.com:9067"),
                    Server.hardcoded("lwd4.zcash-infra.com:9067"),
                    Server.hardcoded("lwd5.zcash-infra.com:9067"),
                    Server.hardcoded("lwd6.zcash-infra.com:9067"),
                    Server.hardcoded("lwd7.zcash-infra.com:9067"),
                    Server.hardcoded("lwd8.zcash-infra.com:9067")
                ]
            )
        }
        
        return servers
    }
    
    public static func defaultEndpoint(for network: NetworkType) -> LightWalletEndpoint {
        let defaultHost = network == .mainnet ? ZcashSDKConstants.endpointMainnetAddress : ZcashSDKConstants.endpointTestnetAddress
        let defaultPort = network == .mainnet ? ZcashSDKConstants.endpointMainnetPort : ZcashSDKConstants.endpointTestnetPort

        return LightWalletEndpoint(
            address: defaultHost,
            port: defaultPort,
            secure: true,
            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
        )
    }
}

public struct ZcashSDKEnvironment {
    public var latestCheckpoint: BlockHeight
    public let endpoint: () -> LightWalletEndpoint
    public let memoCharLimit: Int
    public let mnemonicWordsMaxCount: Int
    public let network: ZcashNetwork
    public let requiredTransactionConfirmations: Int
    public let sdkVersion: String
    public let serverConfig: () -> UserPreferencesStorage.ServerConfig
    public let servers: [Server]
    public let shieldingThreshold: Zatoshi
    public let tokenName: String
}

extension LightWalletEndpoint {
    public func server() -> String {
        "\(self.host):\(self.port)"
    }
    
    public func serverConfig(isCustom: Bool = false) -> UserPreferencesStorage.ServerConfig {
        UserPreferencesStorage.ServerConfig(host: host, port: port, isCustom: isCustom)
    }
}
