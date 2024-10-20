//
//  URIParserTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension URIParserClient: TestDependencyKey {
    public static let testValue = Self(
        isValidURI: unimplemented("\(Self.self).isValidURI", placeholder: false),
        checkRP: unimplemented("\(Self.self).checkRP", placeholder: nil)
    )
}
