//
//  WalletConfigProvider.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import Foundation
import Combine
import Utils

struct WalletConfigProvider {
    /// Objects that fetches flags configuration from some source. It can be fetched from user defaults or some backend API for example. It depends
    /// on implementation.
    private let configSourceProvider: WalletConfigSourceProvider
    /// Object that caches provided flags configuration.
    private let cache: WalletConfigProviderCache

    init(configSourceProvider: WalletConfigSourceProvider, cache: WalletConfigProviderCache) {
        self.configSourceProvider = configSourceProvider
        self.cache = cache
    }

    /// Loads flags configuration.
    ///
    /// First `configurationProvider` is used to fetch flags configuration. If that fails then `cache` is used to load flags configuration. And if
    /// that fails `WalletConfig.default` is used.
    ///
    /// Loaded configuration is merged with with `WalletConfig.default` to be sure that all recognized flags are always returned in
    /// configuration.
    ///
    /// Merged configuration is stored in cache.
    func load() -> AnyPublisher<WalletConfig, Never> {
        let publisher = PassthroughSubject<WalletConfig, Never>()
        Task {
            let config = await load()
            publisher.send(config)
            publisher.send(completion: .finished)
        }
        return publisher.eraseToAnyPublisher()
    }

    private func load() async -> WalletConfig {
        let configuration: WalletConfig
        do {
            configuration = try await configSourceProvider.load()
        } catch {
            LoggerProxy.debug("Error when loading feature flags from configuration provider: \(error)")
            if let cachedConfiguration = await cache.load() {
                configuration = cachedConfiguration
            } else {
                configuration = WalletConfig.default
            }
        }

        let finalConfiguration = merge(configuration: configuration, withDefaultConfiguration: WalletConfig.default)

        await cache.store(finalConfiguration)

        return finalConfiguration
    }

    // This is used only in debug menu to change configuration for specific flag
    func update(featureFlag: FeatureFlag, isEnabled: Bool) -> AnyPublisher<Void, Never> {
        let publisher = PassthroughSubject<Void, Never>()
        Task {
            await update(featureFlag: featureFlag, isEnabled: isEnabled)
            publisher.send(Void())
            publisher.send(completion: .finished)
        }
        return publisher.eraseToAnyPublisher()
    }

    private func update(featureFlag: FeatureFlag, isEnabled: Bool) async {
        guard let provider = configSourceProvider as? UserDefaultsWalletConfigStorage else {
            LoggerProxy.debug("This is now only support with UserDefaultsWalletConfigStorage as configurationProvider.")
            return
        }

        await provider.store(featureFlag: featureFlag, isEnabled: isEnabled)
    }

    private func merge(
        configuration: WalletConfig,
        withDefaultConfiguration defaultConfiguration: WalletConfig
    ) -> WalletConfig {
        var rawDefaultFlags = defaultConfiguration.flags
        rawDefaultFlags.merge(configuration.flags, uniquingKeysWith: { $1 })
        return WalletConfig(flags: rawDefaultFlags)
    }
}

protocol WalletConfigSourceProvider {
    func load() async throws -> WalletConfig
}

protocol WalletConfigProviderCache {
    func load() async -> WalletConfig?
    func store(_ configuration: WalletConfig) async
}
