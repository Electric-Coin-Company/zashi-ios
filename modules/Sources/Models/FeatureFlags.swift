//
//  FeatureFlags.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-15-2024.
//

public struct FeatureFlags: Equatable {
    public let flexa: Bool
    public let appLaunchBiometric: Bool

    init(
        flexa: Bool = false,
        appLaunchBiometric: Bool = false
    ) {
        self.flexa = flexa
        self.appLaunchBiometric = appLaunchBiometric
    }
}

public extension FeatureFlags {
    static let initial = FeatureFlags.setup()
}

private extension FeatureFlags {
    static let disabled = FeatureFlags()

    static func setup() -> FeatureFlags {
#if SECANT_DISTRIB
        FeatureFlags.disabled
#elseif SECANT_TESTNET
        FeatureFlags(
            flexa: false,
            appLaunchBiometric: true
        )
#else
        FeatureFlags(
            flexa: true,
            appLaunchBiometric: true
        )
#endif
    }
}
