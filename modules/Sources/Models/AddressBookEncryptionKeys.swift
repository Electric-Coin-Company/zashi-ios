//
//  AddressBookEncryptionKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-30-2024.
//

import Foundation
import CryptoKit

/// Representation of the address book encryption keys
public struct AddressBookEncryptionKeys: Codable, Equatable {
    public let key: SymmetricKey

    public init(key: SymmetricKey) {
        self.key = key
    }
}

extension AddressBookEncryptionKeys {
    public static let empty = Self(
        key: ""
    )
}
