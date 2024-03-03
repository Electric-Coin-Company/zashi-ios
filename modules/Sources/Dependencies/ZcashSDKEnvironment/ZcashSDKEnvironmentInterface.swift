//
//  ZcashSDKEnvironmentInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

import UserDefaults

extension DependencyValues {
    public var zcashSDKEnvironment: ZcashSDKEnvironment {
        get { self[ZcashSDKEnvironment.self] }
        set { self[ZcashSDKEnvironment.self] = newValue }
    }
}

extension ZcashSDKEnvironment {
    public enum Servers: String, CaseIterable, Equatable {
        public enum Constants {
            public static let udServerKey = "zashi_udServerKey"
            public static let udCustomServerKey = "zashi_udCustomServerKey"
        }
        
        case mainnet
        case naNW
        case saNW
        case euNW
        case aiNW
        case custom
        
        public func server() -> String {
            switch self {
            case .mainnet: return "mainnet.lightwalletd.com:9067"
            case .naNW: return "na.lightwalletd.com:443"
            case .saNW: return "sa.lightwalletd.com:443"
            case .euNW: return "eu.lightwalletd.com:443"
            case .aiNW: return "ai.lightwalletd.com:443"
            case .custom: return "custom"
            }
        }
        
        public func lightWalletEndpoint(_ userDefaults: UserDefaultsClient) -> LightWalletEndpoint? {
            switch self {
            case .mainnet:
                return LightWalletEndpoint(
                    address: "mainnet.lightwalletd.com",
                    port: 9067,
                    secure: true,
                    streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
                )
            case .naNW, .saNW, .euNW, .aiNW:
                return LightWalletEndpoint(
                    address: String(self.server().dropLast(4)),
                    port: 443,
                    secure: true,
                    streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
                )
            case .custom:
                let udKey = ZcashSDKEnvironment.Servers.Constants.udCustomServerKey
                if let storedCustomServer = userDefaults.objectForKey(udKey) as? String{
                    // remove http:// or https:// from the input if present
                    var input = storedCustomServer
                    
                    let http = "http://"
                    let https = "https://"
                    if input.contains(https) {
                        input = String(input.dropFirst(https.count))
                    } else if input.contains(http) {
                        input = String(input.dropFirst(http.count))
                    }

                    let split = input.split(separator: ":")
                    
                    if let portString = split.last, let port = Int(portString) {
                        var host = ""
                        
                        if split.count == 2, let first = split.first {
                            host = String(first)
                        } else if split.count == 3, let first = split.first {
                            let second = split[1]
                            
                            host = "\(String(first))\(String(second))"
                        }
                        
                        return LightWalletEndpoint(
                            address: host,
                            port: port,
                            secure: true,
                            streamingCallTimeoutInMillis: ZcashSDKConstants.streamingCallTimeoutInMillis
                        )
                    }
                }

                return nil
            }
        }
    }

    public enum ZcashSDKConstants {
        static let endpointMainnetAddress = "mainnet.lightwalletd.com"
        static let endpointTestnetAddress = "lightwalletd.testnet.electriccoin.co"
        static let endpointPort = 9067
        static let mnemonicWordsMaxCount = 24
        static let requiredTransactionConfirmations = 10
        static let streamingCallTimeoutInMillis = Int64(10 * 60 * 60 * 1000) // ten hours
    }

    public static func endpointString(for network: ZcashNetwork) -> String {
        switch network.networkType {
        case .testnet:
            return ZcashSDKConstants.endpointTestnetAddress
        case .mainnet:
            return ZcashSDKConstants.endpointMainnetAddress
        }
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
    public let shieldingThreshold: Zatoshi
    public let tokenName: String
}
