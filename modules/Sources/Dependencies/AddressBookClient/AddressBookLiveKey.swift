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
            resetAccount: { account in
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    throw AddressBookClientError.documentsFolder
                }

                let filenameForEncryptedFile = try filenameForEncryptedFile(account: account)
                let fileURL = documentsDirectory.appendingPathComponent(filenameForEncryptedFile)

                try FileManager.default.removeItem(at: fileURL)

                @Dependency(\.remoteStorage) var remoteStorage

                // try to remove the remote as well
                try? remoteStorage.removeFile(filenameForEncryptedFile)
                
                latestKnownContacts = nil
            },
            allLocalContacts: { account in
                // return latest known contacts or load ones for the first time
                guard latestKnownContacts == nil else {
                    return (latestKnownContacts ?? .empty, .notAttempted)
                }

                // contacts haven't been loaded from the local storage yet, do it
                do {
                    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        throw AddressBookClientError.documentsFolder
                    }

                    // Try to find and get the data from the encrypted file with the latest encryption version
                    let encryptedFileURL = documentsDirectory.appendingPathComponent(try AddressBookClient.filenameForEncryptedFile(account: account))

                    if let contactsData = try? Data(contentsOf: encryptedFileURL) {
                        let result = try AddressBookClient.contactsFrom(encryptedData: contactsData, account: account)
                        let contacts = result.0

                        // file exists and was successfully decrypted and parsed;
                        // try to find the unencrypted file and delete it
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        if FileManager.default.fileExists(atPath: unencryptedFileURL.path) {
                            try? FileManager.default.removeItem(at: unencryptedFileURL)
                        }

                        latestKnownContacts = contacts
                        return (contacts, .notAttempted)
                    } else {
                        // Fallback to the unencrypted file check and resolution
                        let unencryptedFileURL = documentsDirectory.appendingPathComponent(Constants.unencryptedFilename)
                        
                        if let contactsData = try? Data(contentsOf: unencryptedFileURL) {
                            // Unencrypted file exists; ensure data are parsed, re-saved as encrypted, and the original file deleted.

                            let result = try AddressBookClient.contactsFrom(plainData: contactsData)
                            var contacts = result.0

                            // try to encrypt and store the data
                            var remoteStoreResult: RemoteStoreResult
                            do {
                                remoteStoreResult = try AddressBookClient.storeContacts(
                                    account: account,
                                    contacts: contacts,
                                    remoteStorage: remoteStorage,
                                    remoteStore: false
                                )

                                let result = try syncContacts(
                                    account: account,
                                    contacts: contacts,
                                    remoteStorage: remoteStorage,
                                    storeAfterSync: true
                                )
                                
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
                            return (.empty, .notAttempted)
                        }
                    }
                } catch {
                    throw error
                }
            },
            syncContacts: { account, contacts in
                let abContacts = contacts ?? latestKnownContacts ?? AddressBookContacts.empty

                let result = try syncContacts(
                    account: account,
                    contacts: abContacts,
                    remoteStorage: remoteStorage
                )

                latestKnownContacts = result.contacts

                return result
            },
            storeContact: { account, contact in
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty

                let result = try syncContacts(
                    account: account,
                    contacts: abContacts,
                    remoteStorage: remoteStorage,
                    storeAfterSync: false
                )
                
                var syncedContacts = result.contacts

                // if already exists, remove it
                if syncedContacts.contacts.contains(contact) {
                    syncedContacts.contacts.remove(contact)
                }
                
                syncedContacts.contacts.append(contact)
                
                let remoteStoreResult = try storeContacts(
                    account: account,
                    contacts: syncedContacts,
                    remoteStorage: remoteStorage
                )
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return (syncedContacts, remoteStoreResult)
            },
            deleteContact: { account, contact in
                let abContacts = latestKnownContacts ?? AddressBookContacts.empty
                
                let result = try syncContacts(
                    account: account,
                    contacts: abContacts,
                    remoteStorage: remoteStorage,
                    storeAfterSync: false
                )
                
                var syncedContacts = result.contacts

                // if it doesn't exist, do nothing
                guard syncedContacts.contacts.contains(contact) else {
                    return (syncedContacts, .notAttempted)
                }
                
                syncedContacts.contacts.remove(contact)
                
                let remoteStoreResult = try storeContacts(
                    account: account,
                    contacts: syncedContacts,
                    remoteStorage: remoteStorage
                )
                
                // update the latest known contacts
                latestKnownContacts = syncedContacts
                
                return (syncedContacts, remoteStoreResult)
            }
        )
    }
    
    private static func syncContacts(
        account: Account,
        contacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        storeAfterSync: Bool = true
    ) throws -> (contacts: AddressBookContacts, remoteStoreResult: RemoteStoreResult) {
        // Ensure remote contacts are prepared
        var remoteContacts: AddressBookContacts = .empty
        var shouldUpdateRemote = false
        var cannotUpdateRemote = false

        do {
            let filenameForEncryptedFile = try AddressBookClient.filenameForEncryptedFile(account: account)
            let encryptedData = try remoteStorage.loadDataFromFile(filenameForEncryptedFile)
            let result = try AddressBookClient.contactsFrom(encryptedData: encryptedData, account: account)
            remoteContacts = result.0
        } catch RemoteStorageClient.RemoteStorageError.fileDoesntExist {
            // If the remote file doesn't exist, always try to write it when
            // storeAfterSync is true.
            shouldUpdateRemote = true
        } catch RemoteStorageClient.RemoteStorageError.containerURL {
            // Remember that we got this error when setting remoteStoreResult.
            cannotUpdateRemote = true
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
            
            for i in 0..<syncedContacts.contacts.count {
                let contact = syncedContacts.contacts[i]
                
                if $0.id == contact.id {
                    notFound = false
                    
                    // If the timestamps are equal, the local entry takes priority.
                    if $0.lastUpdated >= contact.lastUpdated {
                        syncedContacts.contacts[i].name = $0.name
                        syncedContacts.contacts[i].lastUpdated = $0.lastUpdated
                        shouldUpdateRemote = true
                    }
                    break
                }
            }
            
            if notFound {
                syncedContacts.contacts.append($0)
                shouldUpdateRemote = true
            }
        }

        var remoteStoreResult = RemoteStoreResult.notAttempted

        if storeAfterSync {
            remoteStoreResult = try storeContacts(
                account: account,
                contacts: syncedContacts,
                remoteStorage: remoteStorage,
                remoteStore: shouldUpdateRemote && !cannotUpdateRemote
            )
            
            if cannotUpdateRemote {
                remoteStoreResult = .failure
            }
        }
        
        return (syncedContacts, remoteStoreResult)
    }
    
    private static func storeContacts(
        account: Account,
        contacts: AddressBookContacts,
        remoteStorage: RemoteStorageClient,
        remoteStore: Bool = true
    ) throws -> RemoteStoreResult {
        // encrypt data
        let encryptedContacts = try AddressBookClient.encryptContacts(contacts, account: account)

        let filenameForEncryptedFile = try AddressBookClient.filenameForEncryptedFile(account: account)

        // store encrypted data to the local storage
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw AddressBookClientError.documentsFolder
        }

        let fileURL = documentsDirectory.appendingPathComponent(filenameForEncryptedFile)
        try encryptedContacts.write(to: fileURL)

        // store encrypted data to the remote storage
        if remoteStore {
            do {
                try remoteStorage.storeDataToFile(encryptedContacts, filenameForEncryptedFile)
                return .success
            } catch {
                return .failure
            }
        } else {
            return .notAttempted
        }
    }
    
    private static func filenameForEncryptedFile(account: Account) throws -> String {
        @Dependency(\.walletStorage) var walletStorage

        guard let encryptionKeys = try? walletStorage.exportAddressBookEncryptionKeys(), let addressBookKey = encryptionKeys.getCached(account: account) else {
            throw AddressBookClientError.missingEncryptionKey
        }

        guard let filename = addressBookKey.fileIdentifier() else {
            throw AddressBookClientError.fileIdentifier
        }
        
        return filename
    }
}
