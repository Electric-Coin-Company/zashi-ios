//
//  NumberFormatterTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension NumberFormatterClient: TestDependencyKey {
    static let testValue = Self(
        string: XCTUnimplemented("\(Self.self).string", placeholder: nil),
        number: XCTUnimplemented("\(Self.self).number", placeholder: nil)
    )
}

extension NumberFormatterClient {
    static let noOp = Self(
        string: { _ in nil },
        number: { _ in nil }
    )
}
