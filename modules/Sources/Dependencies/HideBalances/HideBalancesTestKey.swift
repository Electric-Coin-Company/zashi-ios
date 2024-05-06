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
        prepare: XCTUnimplemented("\(Self.self).prepare"),
        value: XCTUnimplemented("\(Self.self).value", placeholder: .init(false)),
        updateValue: XCTUnimplemented("\(Self.self).updateValue")
    )
}

extension HideBalancesClient {
    public static let noOp = Self(
        prepare: { },
        value: { .init(false) },
        updateValue: { _ in }
    )
}
