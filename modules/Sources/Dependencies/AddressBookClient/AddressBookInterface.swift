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
    public let allLocalContacts: (Zip32Account) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let syncContacts: (Zip32Account, AddressBookContacts?) async throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let storeContact: (Zip32Account, Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
    public let deleteContact: (Zip32Account, Contact) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult)
}
