//
//  FeatureFlags.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

enum FeatureFlag: String, CaseIterable, Codable {
    case firstFeatureFlag
    case secondFeatureFlag

    var enabledByDefault: Bool {
        switch self {
        case .firstFeatureFlag:
            return true
        case .secondFeatureFlag:
            return false
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
