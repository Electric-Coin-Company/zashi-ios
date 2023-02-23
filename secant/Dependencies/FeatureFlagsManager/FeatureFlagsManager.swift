//
//  FeatureFlagsManager.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import Foundation

struct FeatureFlagsManager {
    private let configurationProvider: FeatureFlagsConfigurationProvider
    private let cache: FeatureFlagsManagerCache

    init(configurationProvider: FeatureFlagsConfigurationProvider, cache: FeatureFlagsManagerCache) {
        self.configurationProvider = configurationProvider
        self.cache = cache
    }

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

    private func merge(
        configuration: FeatureFlagsConfiguration,
        withDefaultConfiguration defaultConfiguration: FeatureFlagsConfiguration
    ) -> FeatureFlagsConfiguration {
        // Merge config that we received from provider with default config. Provider may return only subset of flags or it can return more flags
        // than we can recognize. Here we should make configuration that respects what is returned from provider and has all the flags that we can
        // recognize.
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
