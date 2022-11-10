//
//  AppVersionTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension AppVersionClient: TestDependencyKey {
    static let testValue = Self(
        appVersion: XCTUnimplemented("\(Self.self).appVersion", placeholder: ""),
        appBuild: XCTUnimplemented("\(Self.self).appBuild", placeholder: "")
    )
}
