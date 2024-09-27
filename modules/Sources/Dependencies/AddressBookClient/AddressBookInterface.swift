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

@DependencyClient
public struct AddressBookClient {
    public let allContacts: () async throws -> IdentifiedArrayOf<ABRecord>
    public let storeContact: (ABRecord) async throws -> IdentifiedArrayOf<ABRecord>
    public let deleteContact: (ABRecord) async throws -> IdentifiedArrayOf<ABRecord>
}
