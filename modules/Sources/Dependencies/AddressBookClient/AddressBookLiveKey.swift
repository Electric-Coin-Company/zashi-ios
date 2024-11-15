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
    
    public enum RemoteStoreResult: Equatable {
        case failure
        case notAttempted
        case success
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
                    return (latestKnownContacts ?? .empty, nil)
                }

                // contacts haven't been loaded from the local storage yet, do it
                do {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        throw AddressBookClientError.documentsFolder
                    }

                    // Try to find and get the data from the encrypted file with the latest encryption version
                    let encryptedFileURL = documentsDirectory.appendingPathComponent(try AddressBookClient.filenameForEncryptedFile())

                    if let contactsData = try? Data(contentsOf: encryptedFileURL) {
                        let contacts = try AddressBookClient.contactsFrom(encryptedData: contactsData)
                        
                        // file exists and was successfully decrypted and parsed;
                        // try to find the unencrypted file and delete it
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        if FileManager.default.fileExists(atPath: unencryptedFileURL.path) {
                            try? FileManager.default.removeItem(at: unencryptedFileURL)
                        }

                        latestKnownContacts = contacts
                        return (contacts, nil)
                    } else {
                        // Fallback to the unencrypted file check and resolution
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        
                        if let contactsData = try? Data(contentsOf: unencryptedFileURL) {
                            // Unencrypted file exists; ensure data are parsed, re-saved as encrypted, and the original file deleted.

                            var contacts = try AddressBookClient.contactsFrom(contactsData)

                            // try to encrypt and store the data
                            var remoteStoreResult: RemoteStoreResult
                            do {
                                remoteStoreResult = try AddressBookClient.storeContacts(contacts, remoteStorage: remoteStorage, remoteStore: false)

                                let result = try syncContacts(contacts: contacts, remoteStorage: remoteStorage, storeAfterSync: true)
                                remoteStoreResult = result.remoteStoreResult
                                contacts = result.contacts
                            } catch {
                                // the store of the new file failed locally, skip the file remove
                                latestKnownContacts = contacts
                                throw error
                            }
                            
                            try? FileManager.default.removeItem(at: unencryptedFileURL)
                            
                            latestKnownContacts = contacts
                            return (contacts, remoteStoreResult)
                        } else {
                            return (.empty, nil)
                        }
                    }
                } catch {
                    throw error
                }
            },
            syncContacts: {
                let abContacts = $0 ?? latestKnownContacts ?? AddressBookContacts.empty

                let result = try syncContacts(contacts: abContacts, remoteStorage: remoteStorage)

                latestKnownContacts = result.contacts

                return result
            },
            storeContact: {
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty

                let result = try syncContacts(contacts: abContacts, remoteStorage: remoteStorage, storeAfterSync: false)
                var syncedContacts = result.contacts

                // if already exists, remove it
                if syncedContacts.contacts.contains($0) {
                    syncedContacts.contacts.remove($0)
                }
                
                syncedContacts.contacts.append($0)
                
                let remoteStoreResult = try storeContacts(syncedContacts, remoteStorage: remoteStorage)
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return (syncedContacts, remoteStoreResult)
            },
            deleteContact: {
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty
                
                let result = try syncContacts(contacts: abContacts, remoteStorage: remoteStorage, storeAfterSync: false)
                var syncedContacts = result.contacts

                // if it doesn't exist, do nothing
                guard syncedContacts.contacts.contains($0) else {
                    return (syncedContacts, nil)
                }
                
                syncedContacts.contacts.remove($0)
                
                let remoteStoreResult = try storeContacts(syncedContacts, remoteStorage: remoteStorage)
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return (syncedContacts, remoteStoreResult)
            }
        )
    }
    
    private static func syncContacts(
        contacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        storeAfterSync: Bool = true
    ) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult) {
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

        var remoteStoreResult = RemoteStoreResult.notAttempted
        if storeAfterSync {
            remoteStoreResult = try storeContacts(syncedContacts, remoteStorage: remoteStorage, remoteStore: storeData)
        }

        return (syncedContacts, remoteStoreResult)
    }
    
    private static func storeContacts(
        _ abContacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        remoteStore: Bool = true
    ) throws -> RemoteStoreResult {
        // encrypt data
        let encryptedContacts = try AddressBookClient.encryptContacts(abContacts)

        let filenameForEncryptedFile = try AddressBookClient.filenameForEncryptedFile()

        // store encrypted data to the local storage
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AddressBookClientError.documentsFolder
        }

        let fileURL = documentsDirectory.appendingPathComponent(filenameForEncryptedFile)
        try encryptedContacts.write(to: fileURL)

        // store encrypted data to the remote storage
        var isRemoteSuccess = remoteStore
        
        if remoteStore {
            do {
                try remoteStorage.storeAddressBookContacts(encryptedContacts, filenameForEncryptedFile)
            } catch {
                isRemoteSuccess = false
            }
        }

        switch (remoteStore, isRemoteSuccess) {
        case (true, true): return .success
        case (true, false): return .failure
        case (false, true): return .notAttempted
        case (false, false): return .notAttempted
        }
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
