//
//  DerivationToolTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import ZcashLightClientKit

extension DerivationToolClient: TestDependencyKey {
    static let testValue = Self(
        deriveViewingKeys: XCTUnimplemented("\(Self.self).deriveViewingKeys", placeholder: []),
        deriveViewingKey: XCTUnimplemented("\(Self.self).deriveViewingKey", placeholder: ""),
        deriveSpendingKeys: XCTUnimplemented("\(Self.self).deriveSpendingKeys", placeholder: []),
        deriveShieldedAddress: XCTUnimplemented("\(Self.self).deriveShieldedAddress", placeholder: ""),
        deriveShieldedAddressFromViewingKey: XCTUnimplemented("\(Self.self).deriveShieldedAddressFromViewingKey", placeholder: ""),
        deriveTransparentAddress: XCTUnimplemented("\(Self.self).deriveTransparentAddress", placeholder: ""),
        deriveUnifiedViewingKeysFromSeed: XCTUnimplemented("\(Self.self).deriveUnifiedViewingKeysFromSeed", placeholder: []),
        deriveUnifiedAddressFromUnifiedViewingKey:
            XCTUnimplemented("\(Self.self).deriveUnifiedAddressFromUnifiedViewingKey", placeholder: TestUnifiedAddress()),
        deriveTransparentAddressFromPublicKey: XCTUnimplemented("\(Self.self).deriveTransparentAddressFromPublicKey", placeholder: ""),
        deriveTransparentPrivateKey: XCTUnimplemented("\(Self.self).deriveTransparentPrivateKey", placeholder: ""),
        deriveTransparentAddressFromPrivateKey: XCTUnimplemented("\(Self.self).deriveTransparentAddressFromPrivateKey", placeholder: ""),
        isValidExtendedViewingKey: XCTUnimplemented("\(Self.self).isValidExtendedViewingKey", placeholder: false),
        isValidTransparentAddress: XCTUnimplemented("\(Self.self).isValidTransparentAddress", placeholder: false),
        isValidShieldedAddress: XCTUnimplemented("\(Self.self).isValidShieldedAddress", placeholder: false),
        isValidZcashAddress: XCTUnimplemented("\(Self.self).isValidZcashAddress", placeholder: false)
    )
}

extension DerivationToolClient {
    struct TestUnifiedAddress: UnifiedAddress {
        var tAddress: ZcashLightClientKit.TransparentAddress
        var zAddress: ZcashLightClientKit.SaplingShieldedAddress
        
        init(tAddress: ZcashLightClientKit.TransparentAddress = "", zAddress: ZcashLightClientKit.SaplingShieldedAddress = "") {
            self.tAddress = tAddress
            self.zAddress = zAddress
        }
    }
}

extension DerivationToolClient {
    static let noOp = Self(
        deriveViewingKeys: { _, _ in [] },
        deriveViewingKey: { _ in "" },
        deriveSpendingKeys: { _, _ in [] },
        deriveShieldedAddress: { _, _ in "" },
        deriveShieldedAddressFromViewingKey: { _ in "" },
        deriveTransparentAddress: { _, _, _ in "" },
        deriveUnifiedViewingKeysFromSeed: { _, _ in [] },
        deriveUnifiedAddressFromUnifiedViewingKey: { _ in TestUnifiedAddress() },
        deriveTransparentAddressFromPublicKey: { _ in "" },
        deriveTransparentPrivateKey: { _, _, _ in "" },
        deriveTransparentAddressFromPrivateKey: { _ in "" },
        isValidExtendedViewingKey: { _ in false },
        isValidTransparentAddress: { _ in false },
        isValidShieldedAddress: { _ in false },
        isValidZcashAddress: { _ in false }
    )
}
