//
//  AddressBookEncryption.swift
//  Zashi
//
//  Created by Lukáš Korba on 11-11-2024.
//

import ComposableArchitecture

import Models
import Foundation
import CryptoKit
import WalletStorage

extension AddressBookClient {
    /// Encrypts address book contacts. The structure:
    ///     [Unencrypted data]    `encryption version`
    ///     [Unencrypted data]    `salt`
    ///     [Encrypted data]        `address book version`
    ///     [Encrypted data]        `timestamp`
    ///     [Encrypted data]        `contacts`
    ///
    /// This method always produces the latest structure with he latest encryption version.
    static func encryptContacts(_ abContacts: AddressBookContacts) throws -> Data {
        @Dependency(\.walletStorage) var walletStorage
        
        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: 0) else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }
        
        var encryptionVersionData = Data()
        encryptionVersionData.append(contentsOf: intToBytes(AddressBookEncryptionKeys.Constants.version))
        
        var dataForEncryption = Data()
        
        // Serialize `address book version`
        dataForEncryption.append(contentsOf: intToBytes(abContacts.version))
        
        // Serialize `lastUpdated`
        dataForEncryption.append(contentsOf: AddressBookClient.serializeDate(Date()))
        
        // Serialize `contacts.count`
        dataForEncryption.append(contentsOf: intToBytes(abContacts.contacts.count))
        
        // Serialize `contacts`
        abContacts.contacts.forEach { contact in
            let serializedContact = serializeContact(contact)
            dataForEncryption.append(serializedContact)
        }
        
        // Generate a fresh one-time sub-key for encrypting the address book.
        let salt = SymmetricKey(size: SymmetricKeySize.bits256)
        
        return try salt.withUnsafeBytes { salt in
            let salt = Data(salt)
            let subKey = addressBookKey.deriveEncryptionKey(salt: salt)
            
            // Encrypt the serialized address book.
            // CryptoKit encodes the SealedBox as `nonce || ciphertext || tag`.
            let sealed = try ChaChaPoly.seal(dataForEncryption, using: subKey)
            
            // Prepend the encryption version & salt to the SealedBox so we can re-derive the sub-key.
            
            // unencrypted data
            return encryptionVersionData + salt
            // encrypted data
            + sealed.combined
        }
    }
    
    /// Tries to decrypt the data with the structure:
    ///     [Unencrypted data]    `encryption version`
    ///     [Unencrypted data]    `salt`
    ///     [Encrypted data]        `address book version`
    ///     [Encrypted data]        `timestamp`
    ///     [Encrypted data]        `contacts`
    static func contactsFrom(encryptedData: Data) throws -> AddressBookContacts {
        @Dependency(\.walletStorage) var walletStorage
        
        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: 0) else {
            throw AddressBookClient.AddressBookClientError.missingEncryptionKey
        }
        
        var offset = 0
        
        // Deserialize `encryption version`
        let encryptionVersionBytes = encryptedData.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        guard let encryptionVersion = AddressBookClient.bytesToInt(Array(encryptionVersionBytes)) else {
            return .empty
        }
        
        if encryptionVersion == AddressBookEncryptionKeys.Constants.version {
            let encryptedSubData = encryptedData.subdata(in: offset..<encryptedData.count)
            
            // Derive the sub-key for decrypting the address book.
            let salt = encryptedSubData.prefix(upTo: 32)
            let subKey = addressBookKey.deriveEncryptionKey(salt: salt)
            
            // Unseal the encrypted address book.
            let sealed = try ChaChaPoly.SealedBox.init(combined: encryptedSubData.suffix(from: 32))
            let data = try ChaChaPoly.open(sealed, using: subKey)
            offset = 0
            
            // Deserialize `address book version`
            let abVersionCountBytes = data.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
            guard let abVersion =  AddressBookClient.bytesToInt(Array(abVersionCountBytes)) else {
                return .empty
            }
            offset += MemoryLayout<Int>.size
            
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
                version: abVersion,
                contacts: IdentifiedArrayOf(uniqueElements: contacts)
            )
            
            return abContacts
        } else {
            throw AddressBookClientError.encryptionVersionNotSupported
        }
    }
    
    /// Tries to decode the unencrypted data
    ///     [Unencrypted data]        `address book version`
    ///     [Unencrypted data]        `timestamp`
    ///     [Unencrypted data]        `contacts`
    static func contactsFrom(unencryptedData: Data) throws -> AddressBookContacts {
        var offset = 0
        
        // Deserialize `version`
        let versionBytes = unencryptedData.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        // Deserialize and check `address book version`
        guard let version = AddressBookClient.bytesToInt(Array(versionBytes)), version == AddressBookContacts.Constants.version else {
            return .empty
        }
        
        // Deserialize `lastUpdated`
        guard let lastUpdated = AddressBookClient.deserializeDate(from: unencryptedData, at: &offset) else {
            return .empty
        }
        
        // Deserialize `contactsCount`
        let contactsCountBytes = unencryptedData.subdata(in: offset..<(offset + MemoryLayout<Int>.size))
        offset += MemoryLayout<Int>.size
        
        guard let contactsCount = AddressBookClient.bytesToInt(Array(contactsCountBytes)) else {
            return .empty
        }
        
        var contacts: [Contact] = []
        for _ in 0..<contactsCount {
            if let contact = AddressBookClient.deserializeContact(from: unencryptedData, at: &offset) {
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
}
    
// MARK: - Helper methods for the data handling

extension AddressBookClient {
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
