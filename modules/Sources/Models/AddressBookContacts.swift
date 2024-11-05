//
//  AddressBookContacts.swift
//  Zashi
//
//  Created by Lukáš Korba on 09-30-2024.
//

import Foundation
import ComposableArchitecture

public struct AddressBookContacts: Equatable, Codable {
    public enum Constants {
        public static let version = 2
    }
    
    public let lastUpdated: Date
    public let version: Int
    public var contacts: IdentifiedArrayOf<Contact>
    
    public init(lastUpdated: Date, version: Int, contacts: IdentifiedArrayOf<Contact>) {
        self.lastUpdated = lastUpdated
        self.version = version
        self.contacts = contacts
    }
}

public extension AddressBookContacts {
    static let empty = AddressBookContacts(lastUpdated: .distantPast, version: Constants.version, contacts: [])
}
