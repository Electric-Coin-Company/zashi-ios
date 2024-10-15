//
//  FeatureFlags.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-15-2024.
//

public struct FeatureFlags: Equatable {
    public let flexa: Bool
    
    init(
        flexa: Bool = false
    ) {
        self.flexa = flexa
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
            flexa: false
        )
#else
        FeatureFlags(
            flexa: true
        )
#endif
    }
}
