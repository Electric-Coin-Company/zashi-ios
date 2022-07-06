//
//  AppVersionHandler.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 06.07.2022.
//

import Foundation

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
