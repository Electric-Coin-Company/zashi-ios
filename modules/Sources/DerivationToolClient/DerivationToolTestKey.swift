//
//  DerivationToolTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import ZcashLightClientKit
import Utils

extension DerivationToolClient: TestDependencyKey {
    public static let testValue = Self(
        deriveSpendingKey: XCTUnimplemented("\(Self.self).deriveSpendingKey"),
        deriveUnifiedFullViewingKey: XCTUnimplemented("\(Self.self).deriveUnifiedFullViewingKey"),
        isUnifiedAddress: XCTUnimplemented("\(Self.self).isUnifiedAddress", placeholder: false),
        isSaplingAddress: XCTUnimplemented("\(Self.self).isSaplingAddress", placeholder: false),
        isTransparentAddress: XCTUnimplemented("\(Self.self).isTransparentAddress", placeholder: false),
        isZcashAddress: XCTUnimplemented("\(Self.self).isZcashAddress", placeholder: false)
    )
}

extension DerivationToolClient {
    public static let noOp = Self(
        deriveSpendingKey: { _, _, _ in throw "NotImplemented" },
        deriveUnifiedFullViewingKey: { _, _ in throw "NotImplemented" },
        isUnifiedAddress: { _, _ in return false },
        isSaplingAddress: { _, _ in return false },
        isTransparentAddress: { _, _ in return false },
        isZcashAddress: { _, _ in return false }
    )
}
