//
//  FileManagerTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension FileManagerClient: TestDependencyKey {
    public static let testValue = Self(
        url: XCTUnimplemented("\(Self.self).url"),
        fileExists: XCTUnimplemented("\(Self.self).fileExists", placeholder: false),
        removeItem: XCTUnimplemented("\(Self.self).removeItem")
    )
}
