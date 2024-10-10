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
    private enum Constants {
        static let component = "AddressBookData"
    }
    
    public enum AddressBookClientError: Error {
        case missingEncryptionKey
        case documentsFolder
    }
    
    public static let liveValue: AddressBookClient = Self.live()

    public static func live() -> Self {
        var latestKnownContacts: AddressBookContacts?

        @Dependency(\.remoteStorage) var remoteStorage

        return Self(
            allLocalContacts: {
                // return latest known contacts
                guard latestKnownContacts == nil else {
                    if let contacts = latestKnownContacts {
                        return contacts
                    } else {
                        return .empty
                    }
                }

                // contacts haven't been loaded from the locale storage yet, do it
                do {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        throw AddressBookClientError.documentsFolder
                    }
                    let fileURL = documentsDirectory.appendingPathComponent(Constants.component)
                    let encryptedContacts = try Data(contentsOf: fileURL)

                    let decryptedContacts = try AddressBookClient.decryptData(encryptedContacts)
                    latestKnownContacts = decryptedContacts

                    return decryptedContacts
                } catch {
                    throw error
                }
            },
            syncContacts: { contacts in
                // Ensure local contacts are prepared
                var localContacts: AddressBookContacts
                
                if let contacts {
                    localContacts = contacts
                } else {
                    do {
                        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                            throw AddressBookClientError.documentsFolder
                        }
                        let fileURL = documentsDirectory.appendingPathComponent(Constants.component)
                        let encryptedContacts = try Data(contentsOf: fileURL)

                        let decryptedContacts = try AddressBookClient.decryptData(encryptedContacts)
                        localContacts = decryptedContacts

                        return decryptedContacts
                    } catch {
                        throw error
                    }
                }
                
//                let data = try remoteStorage.loadAddressBookContacts()
//                let remoteContacts = try AddressBookClient.decryptData(data)
                
                // Ensure remote contacts are prepared
                
                // Merge strategy
//                print("__LD SYNCING CONTACTS...")
//                print("__LD localContacts \(localContacts)")
//                print("__LD remoteContacts \(remoteContacts)")

                var syncedContacts = localContacts

                // TBD

                return syncedContacts
            },
            storeContact: {
                var abContacts = latestKnownContacts ?? AddressBookContacts.empty
                
                // if already exists, remove it
                if abContacts.contacts.contains($0) {
                    abContacts.contacts.remove($0)
                }
                
                abContacts.contacts.append($0)

                // encrypt data
                let encryptedContacts = try AddressBookClient.encryptContacts(abContacts)
                //let decryptedContacts = try AddressBookClient.decryptData(encryptedContacts)

                // store encrypted data to the local storage
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw AddressBookClientError.documentsFolder
                }
                let fileURL = documentsDirectory.appendingPathComponent(Constants.component)
                try encryptedContacts.write(to: fileURL)
                
                // store encrypted data to the remote storage
                //try remoteStorage.storeAddressBookContacts(encryptedContacts)

                // update the latest known contacts
                latestKnownContacts = abContacts
                
                return abContacts
            },
            deleteContact: {
                var abContacts = latestKnownContacts ?? AddressBookContacts.empty

                // if it doesn't exist, do nothing
                guard abContacts.contacts.contains($0) else {
                    return abContacts
                }
                
                abContacts.contacts.remove($0)

                // encrypt data
                let encryptedContacts = try AddressBookClient.encryptContacts(abContacts)

                // store encrypted data to the local storage
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw AddressBookClientError.documentsFolder
                }
                let fileURL = documentsDirectory.appendingPathComponent(Constants.component)
                try encryptedContacts.write(to: fileURL)
                
                // store encrypted data to the remote storage
                //try remoteStorage.storeAddressBookContacts(encryptedContacts)

                // update the latest known contacts
                latestKnownContacts = abContacts
                
                return abContacts
            }
        )
    }
    
    private static func encryptContacts(_ abContacts: AddressBookContacts) throws -> Data {
        @Dependency(\.walletStorage) var walletStorage

        // TODO: str4d
//        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys() else {
//            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
//        }

        // here you have an array of all contacts
        // you also have a key from the keychain
        var data = Data()

        // Serialize `version`
        data.append(contentsOf: intToBytes(abContacts.version))

        // Serialize `lastUpdated`
        data.append(contentsOf: AddressBookClient.serializeDate(Date()))

        // Serialize `contacts.count`
        data.append(contentsOf: intToBytes(abContacts.contacts.count))

        // Serialize `contacts`
        abContacts.contacts.forEach { contact in
            let serializedContact = serializeContact(contact)
            data.append(serializedContact)
        }

        return data
    }
    
    private static func decryptData(_ data: Data) throws -> AddressBookContacts {
        @Dependency(\.walletStorage) var walletStorage

        // TODO: str4d
//        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys() else {
//            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
//        }

        // here you have the encrypted data from the cloud, the blob
        // you also have a key from the keychain
        
        var offset = 0

        // Deserialize `version`
        let versionBytes = data.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size

        guard let version = AddressBookClient.bytesToInt(Array(versionBytes)) else {
            return .empty
        }
        
        guard version == AddressBookContacts.Constants.version else {
            return .empty
        }

        // Deserialize `lastUpdated`
        guard let lastUpdated = AddressBookClient.deserializeDate(from: data, at: &offset) else {
            return .empty
        }

        // Deserialize `contactsCount`
        let contactsCountBytes = data.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size

        guard let contactsCount = AddressBookClient.bytesToInt(Array(contactsCountBytes)) else {
            return .empty
        }
        
        var contacts: [Contact] = []
        for _ in 0..<contactsCount {
            if let contact = AddressBookClient.deserializeContact(from: data, at: &offset) {
                contacts.append(contact)
            }
        }
        
        let abContacts = AddressBookContacts(
            lastUpdated: lastUpdated,
            version: AddressBookContacts.Constants.version,
            contacts: IdentifiedArrayOf(uniqueElements: contacts)
        )

        return abContacts
    }
    
    private static func serializeContact(_ contact: Contact) -> Data {
        var data = Data()

        // Serialize `lastUpdated`
        data.append(contentsOf: AddressBookClient.serializeDate(contact.lastUpdated))

        // Serialize `address` (length + UTF-8 bytes)
        let addressBytes = stringToBytes(contact.id)
        data.append(contentsOf: intToBytes(addressBytes.count))
        data.append(contentsOf: addressBytes)

        // Serialize `name` (length + UTF-8 bytes)
        let nameBytes = stringToBytes(contact.name)
        data.append(contentsOf: intToBytes(nameBytes.count))
        data.append(contentsOf: nameBytes)

        return data
    }
    
    private static func deserializeContact(from data: Data, at offset: inout Int) -> Contact? {
        // Deserialize `lastUpdated`
        guard let lastUpdated = AddressBookClient.deserializeDate(from: data, at: &offset) else {
            return nil
        }
        
        // Deserialize `address`
        guard let address = readString(from: data, at: &offset) else {
            return nil
        }
        
        // Deserialize `name`
        guard let name = readString(from: data, at: &offset) else {
            return nil
        }
        
        return Contact(address: address, name: name, lastUpdated: lastUpdated)
    }
    
    private static func stringToBytes(_ string: String) -> [UInt8] {
        return Array(string.utf8)
    }

    private static func bytesToString(_ bytes: [UInt8]) -> String? {
        return String(bytes: bytes, encoding: .utf8)
    }
    
    private static func intToBytes(_ value: Int) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    private static func bytesToInt(_ bytes: [UInt8]) -> Int? {
        guard bytes.count == MemoryLayout<Int>.size else {
            return nil
        }
        
        return bytes.withUnsafeBytes {
            $0.load(as: Int.self).bigEndian
        }
    }
    
    private static func serializeDate(_ date: Date) -> [UInt8] {
        // Convert Date to Unix time (number of seconds since 1970)
        let timestamp = Int(date.timeIntervalSince1970)
        
        // Convert the timestamp to bytes
        return AddressBookClient.intToBytes(timestamp)
    }
    
    private static func deserializeDate(from data: Data, at offset: inout Int) -> Date? {
        // Extract the bytes for the timestamp (assume it's stored as an Int)
        let timestampBytes = data.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        // Convert the bytes back to an Int
        guard let timestamp = AddressBookClient.bytesToInt(Array(timestampBytes)) else { return nil }
        
        // Convert the timestamp back to a Date
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    // Helper function to read a string from the data using a length prefix
    private static func readString(from data: Data, at offset: inout Int) -> String? {
        // Read the length first (assumes the length is stored as an Int)
        let lengthBytes = data.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        guard let length = AddressBookClient.bytesToInt(Array(lengthBytes)), length > 0 else { return nil }
        
        // Read the string bytes
        let stringBytes = data.subdata(in: offset..<(offset + length))
        offset += length
        return AddressBookClient.bytesToString(Array(stringBytes))
    }
}
