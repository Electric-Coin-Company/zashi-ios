//
//  DeeplinkTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension DeeplinkClient: TestDependencyKey {
    public static let testValue = Self(
        resolveDeeplinkURL: unimplemented("\(Self.self).resolveDeeplinkURL", placeholder: .home)
    )
}
