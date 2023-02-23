//
//  UserDefaultsFeatureFlagsStorage.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import Foundation

typealias UserDefaultsFeatureFlagsConfigurationProvider = UserDefaultsFeatureFlagsStorage
typealias UserDefaultsFeatureFlagsManagerCache = UserDefaultsFeatureFlagsStorage

struct UserDefaultsFeatureFlagsStorage {
    private let userDefaults = UserDefaults.standard

    enum InternalError: Error {
        case nothingStored
        case cantDeserializeData
    }

    enum Constants {
        static let providerKey = "feature_flags_ud_config_provider"
        static let cacheKey = "feature_flags_ud_config_cache"
    }

    private func load(key: String) async throws -> FeatureFlagsConfiguration {
        guard let data = userDefaults.data(forKey: key) else { throw InternalError.nothingStored }
        do {
            let rawFlags = try PropertyListDecoder().decode(FeatureFlagsConfiguration.RawFlags.self, from: data)
            return FeatureFlagsConfiguration(flags: rawFlags)
        } catch {
            LoggerProxy.debug("Error when deocding feature flags from user defaults: \(error)")
            throw InternalError.cantDeserializeData
        }
    }

    private func store(flags: FeatureFlagsConfiguration.RawFlags, key: String) async {
        do {
            let data = try PropertyListEncoder().encode(flags)
            userDefaults.set(data, forKey: key)
        } catch {
            LoggerProxy.debug("Can't store/encode feature flags when updating user defaults: \(error)")
        }
    }

    // This is used only in debug menu to change configuration for specific flag
    func store(featureFlag: FeatureFlag, isEnabled: Bool) async {
        let currentConfig = (try? await load(key: Constants.providerKey)) ?? FeatureFlagsConfiguration.default
        var rawFlags = currentConfig.flags
        rawFlags[featureFlag] = isEnabled

        await store(flags: rawFlags, key: Constants.providerKey)
    }
}

extension UserDefaultsFeatureFlagsStorage: FeatureFlagsConfigurationProvider {
    func load() async throws -> FeatureFlagsConfiguration {
        return try await load(key: Constants.providerKey)
    }
}

extension UserDefaultsFeatureFlagsStorage: FeatureFlagsManagerCache {
    func load() async -> FeatureFlagsConfiguration? {
        do {
            return try await load(key: Constants.cacheKey)
        } catch {
            LoggerProxy.debug("Can't load feature flags from cache: \(error)")
            return nil
        }
    }

    func store(_ configuration: FeatureFlagsConfiguration) async {
        await store(flags: configuration.flags, key: Constants.cacheKey)
    }
}
