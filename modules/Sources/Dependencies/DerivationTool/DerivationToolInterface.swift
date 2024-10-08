//
//  DerivationToolInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var derivationTool: DerivationToolClient {
        get { self[DerivationToolClient.self] }
        set { self[DerivationToolClient.self] = newValue }
    }
}

@DependencyClient
public struct DerivationToolClient {
    /// Given a seed and a number of accounts, return the associated spending keys.
    /// - Parameter seed: the seed from which to derive spending keys.
    /// - Parameter accountIndex: Index of account to use. Multiple accounts are not fully
    /// supported so the default value of 0 is recommended.
    /// - Returns: the spending keys that correspond to the seed, formatted as Strings.
    public var deriveSpendingKey: ([UInt8], Int, NetworkType) throws -> UnifiedSpendingKey

    /// Given a unified spending key, returns the associated unified viewwing key.
    public var deriveUnifiedFullViewingKey: (UnifiedSpendingKey, NetworkType) throws -> UnifiedFullViewingKey

    /// Checks if given address supports memo
    public var doesAddressSupportMemo: (String, NetworkType) -> Bool = { _, _ in false }

    /// Checks validity of the unified address.
    public var isUnifiedAddress: (String, NetworkType) -> Bool = { _, _ in false }

    /// Checks validity of the shielded address.
    public var isSaplingAddress: (String, NetworkType) -> Bool = { _, _ in false }

    /// Checks validity of the transparent address.
    public var isTransparentAddress: (String, NetworkType) -> Bool = { _, _ in false }

    /// Checks validity of the tex address.
    public var isTexAddress: (String, NetworkType) -> Bool = { _, _ in false }

    /// Checks if given address is a valid zcash address.
    public var isZcashAddress: (String, NetworkType) -> Bool = { _, _ in false }
}
