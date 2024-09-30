//
//  AddressBookLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-27-2024.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

import Models
import RemoteStorage
import Combine

import WalletStorage

extension AddressBookClient: DependencyKey {
    public enum AddressBookClientError: Error {
        case missingEncryptionKey
    }
    
    public static let liveValue: AddressBookClient = Self.live()

    public static func live() -> Self {
        let latestKnownContacts = CurrentValueSubject<IdentifiedArrayOf<ABRecord>?, Never>(nil)

        @Dependency(\.remoteStorage) var remoteStorage

        return Self(
            allContacts: {
                // return latest known contacts
                guard latestKnownContacts.value == nil else {
                    if let contacts = latestKnownContacts.value {
                        return contacts
                    } else {
                        return []
                    }
                }
                
                // contacts haven't been loaded from the remote storage yet, do it
//                do {
//                    let data = try await remoteStorage.loadAddressBookContacts()
//
//                    let storedContacts = try AddressBookClient.decryptData(data)
//                    latestKnownContacts.value = storedContacts
//
//                    return storedContacts
//                } catch RemoteStorageClient.RemoteStorageError.fileDoesntExist {
//                    return []
//                } catch {
//                    throw error
//                }
                return []
            },
            storeContact: {
                var contacts = latestKnownContacts.value ?? []

                // if already exists, remove it
                if contacts.contains($0) {
                    contacts.remove($0)
                }
                
                contacts.append($0)

                // push encrypted data to the remote storage
                //try await remoteStorage.storeAddressBookContacts(AddressBookClient.encryptContacts(contacts))
                // TODO: FIXME
                
                // update the latest known contacts
                latestKnownContacts.value = contacts
                
                return contacts
            },
            deleteContact: {
                var contacts = latestKnownContacts.value ?? []

                // if it doesn't exist, do nothing
                guard contacts.contains($0) else {
                    return contacts
                }
                
                contacts.remove($0)

                // push encrypted data to the remote storage
                //try await remoteStorage.storeAddressBookContacts(AddressBookClient.encryptContacts(contacts))

                // update the latest known contacts
                latestKnownContacts.value = contacts
                
                return contacts
            }
        )
    }
    
    private static func encryptContacts(_ contacts: IdentifiedArrayOf<ABRecord>) throws -> Data {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKey = try? walletStorage.exportAddressBookKey() else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }

        // TODO: str4d
        // here you have an array of all contacts
        // you also have a key from the keychain

        return Data()
    }
    
    private static func decryptData(_ data: Data) throws -> IdentifiedArrayOf<ABRecord> {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKey = try? walletStorage.exportAddressBookKey() else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }

        // TODO: str4d
        // here you have the encrypted data from the cloud, the blob
        // you also have a key from the keychain

        return []
    }
}
