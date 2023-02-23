//
//  FeatureFlagsManagerLiveKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation

extension FeatureFlagsManagerClient: DependencyKey {
    static let liveValue = FeatureFlagsManagerClient.live()

    private static var defaultFeatureFlagsManager: FeatureFlagsManager {
        FeatureFlagsManager(
            configurationProvider: UserDefaultsFeatureFlagsConfigurationProvider(),
            cache: UserDefaultsFeatureFlagsManagerCache()
        )
    }

    static func live(featureFlagsManager: FeatureFlagsManager = FeatureFlagsManagerClient.defaultFeatureFlagsManager) -> Self {
        Self(load: { return await featureFlagsManager.load() })
    }
}
