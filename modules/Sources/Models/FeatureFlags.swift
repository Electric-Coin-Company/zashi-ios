//
//  FeatureFlags.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-15-2024.
//

public struct FeatureFlags: Equatable {
    public let flexa: Bool
    public let appLaunchBiometric: Bool

    public init(
        flexa: Bool = false,
        appLaunchBiometric: Bool = false
    ) {
        self.flexa = flexa
        self.appLaunchBiometric = appLaunchBiometric
    }
}

public extension FeatureFlags {
    static let initial = FeatureFlags()
}
