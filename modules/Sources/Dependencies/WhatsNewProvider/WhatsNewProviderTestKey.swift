//
//  WhatsNewProviderTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-14-2024.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension WhatsNewProviderClient: TestDependencyKey {
    public static let testValue = Self(
        latest: unimplemented("\(Self.self).latest", placeholder: .zero),
        all: unimplemented("\(Self.self).all", placeholder: .zero)
    )
}

extension WhatsNewProviderClient {
    public static let noOp = Self(
        latest: { .zero },
        all: { .zero }
    )
}
