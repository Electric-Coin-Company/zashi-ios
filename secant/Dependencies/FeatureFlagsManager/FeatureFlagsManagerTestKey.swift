//
//  FeatureFlagsManagerTestKey.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

extension FeatureFlagsManagerClient: TestDependencyKey {
    static let testValue = Self(
        load: XCTUnimplemented("\(Self.self).load", placeholder: FeatureFlagsConfiguration.default)
    )
}

extension FeatureFlagsManagerClient {
    static let `default` = Self(
        load: { FeatureFlagsConfiguration.default }
    )
}
