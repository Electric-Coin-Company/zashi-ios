//
//  HideBalancesTestKey.swift
//
//
//  Created by Lukáš Korba on 11.11.2023.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Combine

extension HideBalancesClient: TestDependencyKey {
    public static let testValue = Self(
        prepare: unimplemented("\(Self.self).prepare", placeholder: {}()),
        value: unimplemented("\(Self.self).value", placeholder: .init(false)),
        updateValue: unimplemented("\(Self.self).updateValue", placeholder: {}())
    )
}

extension HideBalancesClient {
    public static let noOp = Self(
        prepare: { },
        value: { .init(false) },
        updateValue: { _ in }
    )
}
