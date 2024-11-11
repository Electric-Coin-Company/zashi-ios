//
//  FeatureFlags.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-15-2024.
//

public struct FeatureFlags: Equatable {
    public let addUAtoMemo: Bool
    public let appLaunchBiometric: Bool
    public let flexa: Bool
    public let selectText: Bool
    public let sendingScreen: Bool

    public init(
        addUAtoMemo: Bool = false,
        appLaunchBiometric: Bool = false,
        flexa: Bool = false,
        selectText: Bool = false,
        sendingScreen: Bool = false
    ) {
        self.addUAtoMemo = addUAtoMemo
        self.appLaunchBiometric = appLaunchBiometric
        self.flexa = flexa
        self.selectText = selectText
        self.sendingScreen = sendingScreen
    }
}

public extension FeatureFlags {
    static let initial = FeatureFlags()
}
