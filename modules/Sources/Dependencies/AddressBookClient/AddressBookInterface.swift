//
//  AddressBookInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import ComposableArchitecture
import Models

extension DependencyValues {
    public var addressBook: AddressBookClient {
        get { self[AddressBookClient.self] }
        set { self[AddressBookClient.self] = newValue }
    }
}

public struct AddressBookClient {
    public let all: () -> IdentifiedArrayOf<ABRecord>
    public let deleteRecipient: (ABRecord) -> Void
    public let name: (String) -> String?
    public let recipientExists: (ABRecord) -> Bool
    public let storeRecipient: (ABRecord) -> Void
}
