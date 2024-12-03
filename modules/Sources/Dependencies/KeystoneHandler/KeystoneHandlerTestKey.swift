//
//  KeystoneHandlerTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-20.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import KeystoneSDK

extension KeystoneHandlerClient: TestDependencyKey {
    public static let testValue = Self(
        decodeQR: unimplemented("\(Self.self).decodeQR", placeholder: nil)
    )
}

extension KeystoneHandlerClient {
    public static let noOp = Self(
        decodeQR: { _ in nil }
    )
}
