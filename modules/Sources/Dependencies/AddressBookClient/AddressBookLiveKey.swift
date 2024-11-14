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
    enum Constants {
        static let unencryptedFilename = "AddressBookData"
        static let int64Size = MemoryLayout<Int64>.size
    }
    
    public enum StoreResult: Equatable {
        case success
        case remoteFailed
    }

    public enum AddressBookClientError: Error {
        case missingEncryptionKey
        case documentsFolder
        case fileIdentifier
        case unencryptedFileStore
        case unencryptedFileDelete
        case encryptionVersionNotSupported
        case subdataRange
    }

    public static let liveValue: AddressBookClient = Self.live()

    public static func live() -> Self {
        var latestKnownContacts: AddressBookContacts?

        @Dependency(\.remoteStorage) var remoteStorage

        return Self(
            allLocalContacts: {
                // return latest known contacts or load ones for the first time
                guard latestKnownContacts == nil else {
                    return latestKnownContacts ?? .empty
                }

                // contacts haven't been loaded from the locale storage yet, do it
                do {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        throw AddressBookClientError.documentsFolder
                    }

                    // Try to find and get the data from the encrypted file with the latest encryption version
                    let encryptedFileURL = documentsDirectory.appendingPathComponent(try AddressBookClient.filenameForEncryptedFile())

                    if let contactsData = try? Data(contentsOf: encryptedFileURL) {
                        let contacts = try AddressBookClient.contactsFrom(encryptedData: contactsData)
                        
                        // file exists and was successfuly decrypted;
                        // try to find the unencrypted file and delete it
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        if FileManager.default.fileExists(atPath: unencryptedFileURL.path) {
                            try? FileManager.default.removeItem(at: unencryptedFileURL)
                        }

                        latestKnownContacts = contacts
                        return contacts
                    } else {
                        // Fallback to the unencrypted file check and resolution
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        
                        if let contactsData = try? Data(contentsOf: unencryptedFileURL) {
                            // Unencrypted file exists; ensure data are parsed, re-saved as encrypted, and file deteled
                            let contacts = try AddressBookClient.contactsFrom(contactsData)

                            // try to encrypt and store the data
                            do {
                                try AddressBookClient.storeContacts(contacts, remoteStorage: remoteStorage, remoteStore: false)
                            } catch {
                                // the store of the new file failed, skip the file remove
                                latestKnownContacts = contacts
                                throw error
                            }
                            
                            try? FileManager.default.removeItem(at: unencryptedFileURL)
                            
                            latestKnownContacts = contacts
                            return contacts
                        } else {
                            return .empty
                        }
                    }
                } catch {
                    throw error
                }
            },
            syncContacts: {
                let abContacts = $0 ?? latestKnownContacts ?? AddressBookContacts.empty

                let syncedContacts =  try syncContacts(contacts: abContacts, remoteStorage: remoteStorage)
                
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
                
                let storeResult = try storeContacts(syncedContacts, remoteStorage: remoteStorage)
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return (syncedContacts, storeResult)
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
        contacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        storeAfterSync: Bool = true
    ) throws -> AddressBookContacts {
        // Ensure remote contacts are prepared
        var remoteContacts: AddressBookContacts = .empty
        var storeData = true

        do {
            let filenameForEncryptedFile = try AddressBookClient.filenameForEncryptedFile()
            let encryptedData = try remoteStorage.loadAddressBookContacts(filenameForEncryptedFile)
            remoteContacts = try AddressBookClient.contactsFrom(encryptedData: encryptedData)
        } catch RemoteStorageClient.RemoteStorageError.fileDoesntExist {
            storeData = false
        } catch RemoteStorageClient.RemoteStorageError.containerURL {
            storeData = false
        } catch {
            throw error
        }

        // Merge strategy
        var syncedContacts = AddressBookContacts(
            lastUpdated: Date(),
            version: AddressBookContacts.Constants.version,
            contacts: contacts.contacts
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
    
    @discardableResult private static func storeContacts(
        _ abContacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        remoteStore: Bool = true
    ) throws -> StoreResult {
        // encrypt data
        let encryptedContacts = try AddressBookClient.encryptContacts(abContacts)

        // store encrypted data to the local storage
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AddressBookClientError.documentsFolder
        }
        
        let filenameForEncryptedFile = try AddressBookClient.filenameForEncryptedFile()

        let fileURL = documentsDirectory.appendingPathComponent(filenameForEncryptedFile)
        try encryptedContacts.write(to: fileURL)
        
        var storeResult = StoreResult.success
        
        // store encrypted data to the remote storage
        if remoteStore {
            do {
                try remoteStorage.storeAddressBookContacts(encryptedContacts, filenameForEncryptedFile)
            } catch {
                storeResult = .remoteFailed
            }
        }
        
        return storeResult
    }
    
    private static func filenameForEncryptedFile() throws -> String {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: 0) else {
            throw AddressBookClientError.missingEncryptionKey
        }

        guard let filename = addressBookKey.fileIdentifier() else {
            throw AddressBookClientError.fileIdentifier
        }
        
        return filename
    }
}
