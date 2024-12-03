//
//  AddressBookEncryptionKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-30-2024.
//

import Foundation
import CryptoKit
import Utils
import DerivationTool
import ZcashLightClientKit

/// Representation of the address book encryption keys
public struct AddressBookEncryptionKeys: Codable, Equatable {
    /// Latest encryption version
    public enum Constants {
        public static let version = 1
    }
    
    var keys: [Int: AddressBookKey]

    public mutating func cacheFor(seed: [UInt8], account: Zip32AccountIndex, network: NetworkType) throws{
        keys[Int(account.index)] = try AddressBookKey(seed: seed, account: account, network: network)
    }

    public func getCached(account: Zip32AccountIndex) -> AddressBookKey? {
        keys[Int(account.index)]
    }
}

extension AddressBookEncryptionKeys {
    public static let empty = Self(
        keys: [:]
    )
}

public struct AddressBookKey: Codable, Equatable, Redactable {
    let key: SymmetricKey

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        key = SymmetricKey(data: try container.decode(Data.self))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try key.withUnsafeBytes { key in
            let key = Data(key)
            try container.encode(key)
        }
    }

    /**
     * Derives the long-term key that can decrypt the given account's encrypted
     * address book.
     *
     * This requires access to the seed phrase. If the app has separate access
     * control requirements for the seed phrase and the address book, this key
     * should be cached in the app's keystore.
     */
    public init(seed: [UInt8], account: Zip32AccountIndex, network: NetworkType) throws {
        self.key = try SymmetricKey(data: DerivationToolClient.live().deriveArbitraryAccountKey(
            [UInt8]("ZashiAddressBookEncryptionV1".utf8),
            seed,
            account,
            network
        ))
    }

    /**
     * Derives a one-time address book encryption key.
     *
     * At encryption time, the one-time property MUST be ensured by generating a
     * random 32-byte salt.
     */
    public func deriveEncryptionKey(
        salt: Data
    ) -> SymmetricKey {
        assert(salt.count == 32)

        guard let info = "encryption_key".data(using: .utf8) else {
            fatalError("Unable to prepare `encryption_key` info")
        }
        
        return HKDF<SHA256>.deriveKey(inputKeyMaterial: key, info: salt + info, outputByteCount: 32)
    }

    /**
     * Derives the filename that this key is able to decrypt.
     */
    public func fileIdentifier() -> String? {
        guard let info = "file_identifier".data(using: .utf8) else {
            fatalError("Unable to prepare `file_identifier` info")
        }

        // Perform HKDF with SHA-256
        let hkdfKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: key, info: info, outputByteCount: 32)
        
        // Convert the HKDF output to a hex string
        let fileIdentifier = hkdfKey.withUnsafeBytes { rawBytes in
            rawBytes.map { String(format: "%02x", $0) }.joined()
        }
        
        // Prepend the prefix to the result
        return "zashi-address-book-\(fileIdentifier)"
    }
}
