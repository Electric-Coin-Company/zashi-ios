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
    public let allLocalContacts: () throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult?)
    public let syncContacts: (AddressBookContacts?) async throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let storeContact: (Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let deleteContact: (Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult?)
}
