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
        deriveSpendingKey: unimplemented("\(Self.self).deriveSpendingKey"),
        deriveUnifiedFullViewingKey: unimplemented("\(Self.self).deriveUnifiedFullViewingKey"),
        doesAddressSupportMemo: unimplemented("\(Self.self).doesAddressSupportMemo", placeholder: false),
        isUnifiedAddress: unimplemented("\(Self.self).isUnifiedAddress", placeholder: false),
        isSaplingAddress: unimplemented("\(Self.self).isSaplingAddress", placeholder: false),
        isTransparentAddress: unimplemented("\(Self.self).isTransparentAddress", placeholder: false),
        isTexAddress: unimplemented("\(Self.self).isTexAddress", placeholder: false),
        isZcashAddress: unimplemented("\(Self.self).isZcashAddress", placeholder: false),
        deriveArbitraryWalletKey: unimplemented("\(Self.self).deriveArbitraryWalletKey"),
        deriveArbitraryAccountKey: unimplemented("\(Self.self).deriveArbitraryAccountKey")
    )
}

extension DerivationToolClient {
    public static let noOp = Self(
        deriveSpendingKey: { _, _, _ in throw "NotImplemented" },
        deriveUnifiedFullViewingKey: { _, _ in throw "NotImplemented" },
        doesAddressSupportMemo: { _, _ in return false },
        isUnifiedAddress: { _, _ in return false },
        isSaplingAddress: { _, _ in return false },
        isTransparentAddress: { _, _ in return false },
        isTexAddress: { _, _ in return false },
        isZcashAddress: { _, _ in return false },
        deriveArbitraryWalletKey: { _, _ in throw "NotImplemented" },
        deriveArbitraryAccountKey: { _, _, _, _ in throw "NotImplemented" }
    )
}
