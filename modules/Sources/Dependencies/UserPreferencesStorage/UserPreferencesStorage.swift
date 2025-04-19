//
//  UserPreferencesStorage.swift
//  Zashi
//
//  Created by Lukáš Korba on 03/18/2022.
//

import Foundation
import UserDefaults
import ZcashLightClientKit

/// Live implementation of the `UserPreferences` using User Defaults
/// according to https://developer.apple.com/documentation/foundation/userdefaults
/// the UserDefaults class is thread-safe.
public struct UserPreferencesStorage {
    public enum Constants: String, CaseIterable {
        case ups_exchangeRate
        case ups_server
    }
    
    public enum UserPreferencesStorageError: Error {
        case exchangeRate
        case serverConfig
    }
    
    /// Default values for all preferences in case there is no value stored (counterparts to `Constants`)
    private let defaultExchangeRate: Data
    private let defaultServer: Data

    private let userDefaults: UserDefaultsClient
    
    public init(
        defaultExchangeRate: Data,
        defaultServer: Data,
        userDefaults: UserDefaultsClient
    ) {
        self.defaultExchangeRate = defaultExchangeRate
        self.defaultServer = defaultServer
        self.userDefaults = userDefaults
    }
    
    /// From when the app is on and uninterrupted
    public var server: ServerConfig? {
        let contentData = getValue(forKey: Constants.ups_server.rawValue, default: defaultServer)

        if let content = try? JSONDecoder().decode(ServerConfig.self, from: contentData) {
            return content
        }
        
        return nil
    }
    
    public func setServer(_ server: ServerConfig) throws {
        do {
            let contentData = try JSONEncoder().encode(server)
            setValue(contentData, forKey: Constants.ups_server.rawValue)
        } catch {
            throw UserPreferencesStorageError.serverConfig
        }
    }

    /// Exchange rate API in the SDK uses TOR and eventually fetches the data from rate providers. This has to be opted in by a user, by default it's off.
    public var exchangeRate: ExchangeRate? {
        let contentData = getValue(forKey: Constants.ups_exchangeRate.rawValue, default: defaultExchangeRate)

        if let content = try? JSONDecoder().decode(ExchangeRate.self, from: contentData) {
            return content
        }
        
        return nil
    }
    
    public func setExchangeRate(_ newValue: ExchangeRate?) throws -> Void {
        do {
            let contentData = try JSONEncoder().encode(newValue)
            setValue(contentData, forKey: Constants.ups_exchangeRate.rawValue)
        } catch {
            throw UserPreferencesStorageError.exchangeRate
        }
    }

    /// Use carefully: Deletes all user preferences from the User Defaults
    public func removeAll() {
        for key in Constants.allCases {
            userDefaults.remove(key.rawValue)
        }
    }
}

private extension UserPreferencesStorage {
    func getValue<Value>(forKey: String, default defaultIfNil: Value) -> Value {
        userDefaults.objectForKey(forKey) as? Value ?? defaultIfNil
    }

    func setValue<Value>(_ value: Value, forKey: String) {
        userDefaults.setValue(value, forKey)
    }
}

// MARK: Exchange Rate

public extension UserPreferencesStorage {
    struct ExchangeRate: Equatable, Codable {
        public let manual: Bool
        public let automatic: Bool

        public init(manual: Bool, automatic: Bool) {
            self.manual = manual
            self.automatic = automatic
        }
    }
}

// MARK: Server Config

public extension UserPreferencesStorage {
    struct ServerConfig: Equatable, Codable {
        public let host: String
        public let port: Int
        public let isCustom: Bool
        
        public init(host: String, port: Int, isCustom: Bool) {
            self.host = host
            self.port = port
            self.isCustom = isCustom
        }
        
        public func serverString() -> String {
            "\(host):\(port)"
        }
        
        public func endpoint(streamingCallTimeoutInMillis: Int64) -> LightWalletEndpoint {
            LightWalletEndpoint(
                address: host,
                port: port,
                secure: true,
                streamingCallTimeoutInMillis: streamingCallTimeoutInMillis
            )
        }
        
        public static func endpoint(for string: String, streamingCallTimeoutInMillis: Int64) -> LightWalletEndpoint? {
            // remove http:// or https:// from the input if present
            var input = string
            
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
                    streamingCallTimeoutInMillis: streamingCallTimeoutInMillis
                )
            }
            
            return nil
        }
        
        public static func config(for string: String, isCustom: Bool, streamingCallTimeoutInMillis: Int64) -> ServerConfig? {
            guard let endpoint = ServerConfig.endpoint(for: string, streamingCallTimeoutInMillis: streamingCallTimeoutInMillis) else {
                return nil
            }
            
            return ServerConfig(host: endpoint.host, port: endpoint.port, isCustom: isCustom)
        }
    }
}
