//
//  LocalAuthenticationTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension LocalAuthenticationClient: TestDependencyKey {
    static let testValue = Self(
        authenticate: XCTUnimplemented("\(Self.self).authenticate", placeholder: false)
    )
}
