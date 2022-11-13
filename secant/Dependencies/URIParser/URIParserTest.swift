//
//  URIParserTest.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension URIParserClient: TestDependencyKey {
    static let testValue = Self(
        isValidURI: XCTUnimplemented("\(Self.self).isValidURI", placeholder: false)
    )
}
