//
//  FeatureFlagsManager.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import Foundation

struct FeatureFlagsManager {
    /// Objects that fetches flags configuration from some source. It can be fetched from user defaults or some backend API for example. It depends
    /// on implementation.
    private let configurationProvider: FeatureFlagsConfigurationProvider
    /// Object that caches provided flags configuration.
    private let cache: FeatureFlagsManagerCache

    init(configurationProvider: FeatureFlagsConfigurationProvider, cache: FeatureFlagsManagerCache) {
        self.configurationProvider = configurationProvider
        self.cache = cache
    }

    /// Loads flags configuration.
    ///
    /// First `configurationProvider` is used to fetch flags configuration. If that fails then `cache` is used to load flags configuration. And if
    /// that fails `FeatureFlagsConfiguration.default` is used.
    ///
    /// Loaded configuration is merged with with `FeatureFlagsConfiguration.default` to be sure that all recognized flags are always returned in
    /// configuration.
    ///
    /// Merged configuration is stored in cache.
    func load() async -> FeatureFlagsConfiguration {
        let configuration: FeatureFlagsConfiguration
        do {
            configuration = try await configurationProvider.load()
        } catch {
            LoggerProxy.debug("Error when loading feature flags from configuration provider: \(error)")
            if let cachedConfiguration = await cache.load() {
                configuration = cachedConfiguration
            } else {
                configuration = FeatureFlagsConfiguration.default
            }
        }

        let finalConfiguration = merge(configuration: configuration, withDefaultConfiguration: FeatureFlagsConfiguration.default)

        await cache.store(finalConfiguration)

        return finalConfiguration
    }

    // This is used only in debug menu to change configuration for specific flag
    func update(featureFlag: FeatureFlag, isEnabled: Bool) async {
        guard let provider = configurationProvider as? UserDefaultsFeatureFlagsStorage else {
            LoggerProxy.debug("This is now only support with UserDefaultsFeatureFlagsStorage as configurationProvider.")
            return
        }

        await provider.store(featureFlag: featureFlag, isEnabled: isEnabled)
    }

    private func merge(
        configuration: FeatureFlagsConfiguration,
        withDefaultConfiguration defaultConfiguration: FeatureFlagsConfiguration
    ) -> FeatureFlagsConfiguration {
        var rawDefaultFlags = defaultConfiguration.flags
        rawDefaultFlags.merge(configuration.flags, uniquingKeysWith: { $1 })
        return FeatureFlagsConfiguration(flags: rawDefaultFlags)
    }
}

protocol FeatureFlagsConfigurationProvider {
    func load() async throws -> FeatureFlagsConfiguration
}

protocol FeatureFlagsManagerCache {
    func load() async -> FeatureFlagsConfiguration?
    func store(_ configuration: FeatureFlagsConfiguration) async
}
