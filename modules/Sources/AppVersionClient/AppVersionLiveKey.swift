//
//  AppVersionLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import Foundation
import ComposableArchitecture

extension AppVersionClient: DependencyKey {
    public static let liveValue = Self(
        appVersion: { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" },
        appBuild: { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "" }
    )
}
