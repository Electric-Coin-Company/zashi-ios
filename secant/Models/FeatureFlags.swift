//
//  FeatureFlags.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

enum FeatureFlag: String, CaseIterable, Codable {
    // These two flags should stay here because those are used in tests. It's not super nice but there is probably no other way.
    case testFlag1
    case testFlag2
    case onboardingFlow

    var enabledByDefault: Bool {
        switch self {
        case .testFlag1, .testFlag2: return false
        case .onboardingFlow: return false
        }
    }
}

struct FeatureFlagsConfiguration: Equatable {
    typealias RawFlags = [FeatureFlag: Bool]

    let flags: RawFlags

    func isEnabled(_ featureFlag: FeatureFlag) -> Bool {
        return flags[featureFlag, default: false]
    }

    static var `default`: FeatureFlagsConfiguration = {
        let defaultSettings = FeatureFlag.allCases.map { ($0, $0.enabledByDefault) }
        return FeatureFlagsConfiguration(flags: Dictionary(uniqueKeysWithValues: defaultSettings))
    }()
}
