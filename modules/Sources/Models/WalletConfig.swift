//
//  WalletConfig.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

public enum FeatureFlag: String, CaseIterable, Codable {
    // These two flags should stay here because those are used in tests. It's not super nice but there is probably no other way.
    case testFlag1
    case testFlag2
    case onboardingFlow
    case testBackupPhraseFlow
    case showFiatConversion

    public var enabledByDefault: Bool {
        switch self {
        case .testFlag1, .testFlag2: return false
        case .onboardingFlow: return false
        case .testBackupPhraseFlow: return false
        case .showFiatConversion: return false
        }
    }
}

public struct WalletConfig: Equatable {
    public typealias RawFlags = [FeatureFlag: Bool]

    public let flags: RawFlags

    public func isEnabled(_ featureFlag: FeatureFlag) -> Bool {
        return flags[featureFlag, default: false]
    }

    public static var `default`: WalletConfig = {
        let defaultSettings = FeatureFlag.allCases
            .filter { $0 != .testFlag1 && $0 != .testFlag2 }
            .map { ($0, $0.enabledByDefault) }

        return WalletConfig(flags: Dictionary(uniqueKeysWithValues: defaultSettings))
    }()
    
    public init(flags: RawFlags) {
        self.flags = flags
    }
}
