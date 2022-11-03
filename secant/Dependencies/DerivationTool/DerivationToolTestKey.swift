//
//  DerivationToolTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import ZcashLightClientKit

extension DerivationToolClient: TestDependencyKey {
    static let testValue = Self(
        deriveUnifiedViewingKeyFromSpendingKey: XCTUnimplemented("\(Self.self).deriveUnifiedViewingKeyFromSpendingKey"),
        deriveSpendingKey: XCTUnimplemented("\(Self.self).deriveSpendingKey"),
        isValidTransparentAddress: XCTUnimplemented("\(Self.self).isValidTransparentAddress", placeholder: false),
        isValidSaplingAddress: XCTUnimplemented("\(Self.self).isValidShieldedAddress", placeholder: false),
        isValidZcashAddress: XCTUnimplemented("\(Self.self).isValidZcashAddress", placeholder: false)
    )
}

extension DerivationToolClient {
    static let noOp = Self(
        deriveUnifiedViewingKeyFromSpendingKey: { _ in throw NSError(domain: "NotImplemented", code: 0, userInfo: nil) },
        deriveSpendingKey: { _, _ in throw NSError(domain: "NotImplemented", code: 0, userInfo: nil) },
        isValidTransparentAddress: { _ in return false },
        isValidSaplingAddress: { _ in return false },
        isValidZcashAddress: { _ in return false }
    )
}
