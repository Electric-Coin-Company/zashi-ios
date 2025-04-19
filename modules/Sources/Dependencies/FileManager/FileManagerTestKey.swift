//
//  FileManagerTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Utils

extension FileManagerClient: TestDependencyKey {
    public static let testValue = Self(
        url: unimplemented("\(Self.self).url", placeholder: .emptyURL),
        fileExists: unimplemented("\(Self.self).fileExists", placeholder: false),
        removeItem: unimplemented("\(Self.self).removeItem", placeholder: {}())
    )
}
