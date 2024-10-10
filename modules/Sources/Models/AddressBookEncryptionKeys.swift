//
//  AddressBookEncryptionKeys.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-30-2024.
//

import Foundation

/// Representation of the address book encryption keys
public struct AddressBookEncryptionKeys: Codable, Equatable {
    public let key: String

    public init(key: String) {
        self.key = key
    }
}

extension AddressBookEncryptionKeys {
    public static let empty = Self(
        key: ""
    )
}
