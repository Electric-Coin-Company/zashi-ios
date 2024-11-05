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
import CryptoKit

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
                    let encryptedContacts: Data
                    
                    do {
                        encryptedContacts = try Data(contentsOf: fileURL)
                    } catch {
                        let syncedContacts = try syncContacts(contacts: .empty, remoteStorage: remoteStorage)
                        latestKnownContacts = syncedContacts
                        return syncedContacts
                    }
                    
                    let decryptedContacts = try AddressBookClient.decryptData(encryptedContacts)
                    latestKnownContacts = decryptedContacts

                    return decryptedContacts
                } catch {
                    throw error
                }
            },
            syncContacts: { contacts in
                let syncedContacts =  try syncContacts(contacts: contacts, remoteStorage: remoteStorage)
                
                latestKnownContacts = syncedContacts

                return syncedContacts
            },
            storeContact: {
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty

                var syncedContacts = try syncContacts(contacts: abContacts, remoteStorage: remoteStorage, storeAfterSync: false)

                // if already exists, remove it
                if syncedContacts.contacts.contains($0) {
                    syncedContacts.contacts.remove($0)
                }
                
                syncedContacts.contacts.append($0)
                
                try storeContacts(syncedContacts, remoteStorage: remoteStorage)
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return syncedContacts
            },
            deleteContact: {
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty
                
                var syncedContacts = try syncContacts(contacts: abContacts, remoteStorage: remoteStorage, storeAfterSync: false)
                
                // if it doesn't exist, do nothing
                guard syncedContacts.contacts.contains($0) else {
                    return syncedContacts
                }
                
                syncedContacts.contacts.remove($0)
                
                try storeContacts(syncedContacts, remoteStorage: remoteStorage)
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return syncedContacts
            }
        )
    }
    
    private static func syncContacts(
        contacts: AddressBookContacts?,
        remoteStorage: RemoteStorageClient,
        storeAfterSync: Bool = true
    ) throws -> AddressBookContacts {
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

        // Ensure remote contacts are prepared
        let data: Data
        var remoteContacts: AddressBookContacts = .empty
        var storeData = true
        
        do {
            data = try remoteStorage.loadAddressBookContacts()
            remoteContacts = try AddressBookClient.decryptData(data)
        } catch RemoteStorageClient.RemoteStorageError.fileDoesntExist {
            storeData = false
        } catch {
            throw error
        }

        // TMP
//      let rContacts: [Contact] = [
//          Contact(address: "Ar", name: "ar", lastUpdated: Date.init(timeIntervalSince1970: 1730796715)),
//          Contact(address: "C", name: "cle", lastUpdated: Date.init(timeIntervalSince1970: 1730796315)),
//          Contact(address: "D", name: "dr", lastUpdated: Date.init(timeIntervalSince1970: 1730796315))
//      ]
//      let idContacts = IdentifiedArray(rContacts)
//      var remoteContacts = AddressBookContacts(lastUpdated: Date(), version: 2, contacts: idContacts)
//
//      let lContacts: [Contact] = [
//          Contact(address: "Al", name: "al", lastUpdated: Date.init(timeIntervalSince1970: 1730796615)),
//          Contact(address: "Bl", name: "bl", lastUpdated: Date.init(timeIntervalSince1970: 1730796515)),
//          Contact(address: "C", name: "cl", lastUpdated: Date.init(timeIntervalSince1970: 1730796415)),
//          Contact(address: "D", name: "dl", lastUpdated: Date.init(timeIntervalSince1970: 1730796215)),
//      ]
//      let idlContacts = IdentifiedArray(lContacts)
//      var localContacts = AddressBookContacts(lastUpdated: Date(), version: 2, contacts: idlContacts)

        // Merge strategy
        var syncedContacts = AddressBookContacts(
            lastUpdated: Date(),
            version: AddressBookContacts.Constants.version,
            contacts: localContacts.contacts
        )

        remoteContacts.contacts.forEach {
            var notFound = true
            var indexToUpdate = -1
            
            for i in 0..<syncedContacts.contacts.count {
                let contact = syncedContacts.contacts[i]
                
                if $0.id == contact.id {
                    notFound = false
                    
                    if $0.lastUpdated > contact.lastUpdated {
                        indexToUpdate = i
                    }
                    
                    break
                }
            }
            
            if indexToUpdate > -1 {
                syncedContacts.contacts[indexToUpdate].name = $0.name
                syncedContacts.contacts[indexToUpdate].lastUpdated = $0.lastUpdated
            }
            
            if notFound {
                syncedContacts.contacts.append($0)
            }
        }

        if storeAfterSync {
            try storeContacts(syncedContacts, remoteStorage: remoteStorage, remoteStore: storeData)
        }

        return syncedContacts
    }
    
    private static func storeContacts(
        _ abContacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        remoteStore: Bool = true
    ) throws {
        // encrypt data
        let encryptedContacts = try AddressBookClient.encryptContacts(abContacts)

        // store encrypted data to the local storage
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AddressBookClientError.documentsFolder
        }
        let fileURL = documentsDirectory.appendingPathComponent(Constants.component)
        try encryptedContacts.write(to: fileURL)
        
        // store encrypted data to the remote storage
        if remoteStore {
            try remoteStorage.storeAddressBookContacts(encryptedContacts)
        }
    }

    private static func encryptContacts(_ abContacts: AddressBookContacts) throws -> Data {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: 0) else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }

        // here you have an array of all contacts
        // you also have a key from the keychain
        var versionData = Data()
        var data = Data()

        // Serialize `version`
        versionData.append(contentsOf: intToBytes(abContacts.version))

        // Serialize `lastUpdated`
        data.append(contentsOf: AddressBookClient.serializeDate(Date()))

        // Serialize `contacts.count`
        data.append(contentsOf: intToBytes(abContacts.contacts.count))

        // Serialize `contacts`
        abContacts.contacts.forEach { contact in
            let serializedContact = serializeContact(contact)
            data.append(serializedContact)
        }

        // Generate a fresh one-time sub-key for encrypting the address book.
        let salt = SymmetricKey(size: SymmetricKeySize.bits256)
        return try salt.withUnsafeBytes { salt in
            let salt = Data(salt)
            let subKey = addressBookKey.deriveEncryptionKey(salt: salt)

            // Encrypt the serialized address book.
            // CryptoKit encodes the SealedBox as `nonce || ciphertext || tag`.
            let sealed = try ChaChaPoly.seal(data, using: subKey)

            // Prepend the version & salt to the SealedBox so we can re-derive the sub-key.
            return versionData + salt + sealed.combined
        }
    }
    
    private static func decryptData(_ encrypted: Data) throws -> AddressBookContacts {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: 0) else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }

        var offset = 0

        // Deserialize `version`
        let versionBytes = encrypted.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size

        guard let version = AddressBookClient.bytesToInt(Array(versionBytes)) else {
            return .empty
        }

        if version == AddressBookContacts.Constants.version {
            let subData = encrypted.subdata(in: offset..<encrypted.count)

            return try decryptLatestVersionData(subData, addressBookKey: addressBookKey)
        } else if version == 1 {
            return try decryptV1Data(encrypted)
        } else {
            return .empty
        }
    }
    
    private static func decryptV1Data(_ encrypted: Data) throws -> AddressBookContacts {
        var offset = MemoryLayout<Int>.size

        // Deserialize `lastUpdated`
        guard let lastUpdated = AddressBookClient.deserializeDate(from: encrypted, at: &offset) else {
            return .empty
        }

        // Deserialize `contactsCount`
        let contactsCountBytes = encrypted.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size

        guard let contactsCount = AddressBookClient.bytesToInt(Array(contactsCountBytes)) else {
            return .empty
        }
        
        var contacts: [Contact] = []
        for _ in 0..<contactsCount {
            if let contact = AddressBookClient.deserializeContact(from: encrypted, at: &offset) {
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

    private static func decryptLatestVersionData(_ encrypted: Data, addressBookKey: AddressBookKey) throws -> AddressBookContacts {
        var offset = 0
        
        // Derive the sub-key for decrypting the address book.
        let salt = encrypted.prefix(upTo: 32)
        let subKey = addressBookKey.deriveEncryptionKey(salt: salt)

        // Unseal the encrypted address book.
        let sealed = try ChaChaPoly.SealedBox.init(combined: encrypted.suffix(from: 32))
        let data = try ChaChaPoly.open(sealed, using: subKey)

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
