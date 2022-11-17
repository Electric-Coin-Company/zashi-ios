//
//  UserDefaultsTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
    static let testValue = Self(
        objectForKey: XCTUnimplemented("\(Self.self).objectForKey", placeholder: nil),
        remove: XCTUnimplemented("\(Self.self).remove"),
        setValue: XCTUnimplemented("\(Self.self).setValue"),
        synchronize: XCTUnimplemented("\(Self.self).synchronize", placeholder: false)
    )
}

extension UserDefaultsClient {
    static let noOp = Self(
        objectForKey: { _ in nil },
        remove: { _ in },
        setValue: { _, _ in },
        synchronize: { false }
    )
}
