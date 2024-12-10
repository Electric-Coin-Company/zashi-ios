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
    /// - Parameter accountIndex: the ZIP 32 index of the account
    /// - Returns: the spending keys that correspond to the seed, formatted as Strings.
    public var deriveSpendingKey: ([UInt8], Zip32AccountIndex, NetworkType) throws -> UnifiedSpendingKey

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

    
    /// Derives and returns a UnifiedAddress from a UnifiedFullViewingKey
    /// - Parameter ufvk: UTF-8 encoded String to validate
    /// - Returns: true `UnifiedAddress`
    public var deriveUnifiedAddressFrom: (String, NetworkType) throws -> UnifiedAddress

    /// Derives and returns a ZIP 32 Arbitrary Key from the given seed at the "wallet level", i.e.
    /// directly from the seed with no ZIP 32 path applied.
    ///
    /// The resulting key will be the same across all networks (Zcash mainnet, Zcash testnet,
    /// OtherCoin mainnet, and so on). You can think of it as a context-specific seed fingerprint
    /// that can be used as (static) key material.
    ///
    /// - Parameter contextString: a globally-unique non-empty sequence of at most 252 bytes that identifies the desired context.
    /// - Parameter seed: `[Uint8]` seed bytes
    /// - Throws:
    ///     - `derivationToolInvalidAccount` if the `accountIndex` is invalid.
    ///     - some `ZcashError.rust*` error if the derivation fails.
    /// - Returns a `[Uint8]`
    public var deriveArbitraryWalletKey: ([UInt8], [UInt8]) throws -> [UInt8]

    /// Derives and returns a ZIP 32 Arbitrary Key from the given seed at the account level.
    ///
    /// - Parameter contextString: a globally-unique non-empty sequence of at most 252 bytes that identifies the desired context.
    /// - Parameter seed: `[Uint8]` seed bytes
    /// - Parameter accountIndex: the ZIP 32 index of the account
    /// - Throws:
    ///     - `derivationToolInvalidAccount` if the `accountIndex` is invalid.
    ///     - some `ZcashError.rust*` error if the derivation fails.
    /// - Returns a `[Uint8]`
    public var deriveArbitraryAccountKey: ([UInt8], [UInt8], Zip32AccountIndex, NetworkType) throws -> [UInt8]
}
