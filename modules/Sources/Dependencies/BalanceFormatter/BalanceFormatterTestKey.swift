//
//  BalanceFormatterTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 14.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension BalanceFormatterClient: TestDependencyKey {
    public static let testValue = Self(
        convert: unimplemented("\(Self.self).convert", placeholder: .placeholer)
    )
}

extension BalanceFormatterClient {
    public static let noOp = Self(
        convert: { _, _, _ in .placeholer }
    )
}
