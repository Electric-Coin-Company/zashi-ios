//
//  AppVersionHandler.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 06.07.2022.
//

import Foundation
import ComposableArchitecture

struct AppVersionHandler {
    let appVersion: () -> String
    let appBuild: () -> String
}

extension AppVersionHandler {
    static let live = AppVersionHandler(
        appVersion: { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" },
        appBuild: { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "" }
    )

    static let test = AppVersionHandler(
        appVersion: { "0.0.1" },
        appBuild: { "31" }
    )
}

private enum AppVersionHandlerKey: DependencyKey {
    static let liveValue = AppVersionHandler.live
    static let testValue = AppVersionHandler.test
}

extension DependencyValues {
    var appVersionHandler: AppVersionHandler {
        get { self[AppVersionHandlerKey.self] }
        set { self[AppVersionHandlerKey.self] = newValue }
    }
}
