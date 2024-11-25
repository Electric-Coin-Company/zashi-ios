//
//  AddressBookInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import ComposableArchitecture
import Models
import ZcashLightClientKit

extension DependencyValues {
    public var addressBook: AddressBookClient {
        get { self[AddressBookClient.self] }
        set { self[AddressBookClient.self] = newValue }
    }
}

@DependencyClient
public struct AddressBookClient {
    public let allLocalContacts: (Zip32AccountIndex) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let syncContacts: (Zip32AccountIndex, AddressBookContacts?) async throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let storeContact: (Zip32AccountIndex, Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let deleteContact: (Zip32AccountIndex, Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
}
