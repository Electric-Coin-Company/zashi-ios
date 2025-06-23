//
//  UMSerialization.swift
//  modules
//
//  Created by Lukáš Korba on 03.02.2025.
//

import Foundation
import ComposableArchitecture
import WalletStorage
import ZcashLightClientKit
import Models
import CryptoKit
import Utils

public struct UserMetadata: Codable {
    public enum Constants {
        public static let version = 2
    }
    
    public enum CodingKeys: CodingKey {
        case version
        case lastUpdated
        case accountMetadata
    }
    
    let version: Int
    let lastUpdated: Int64
    let accountMetadata: UMAccount
    
    public init(version: Int, lastUpdated: Int64, accountMetadata: UMAccount) {
        self.version = version
        self.lastUpdated = lastUpdated
        self.accountMetadata = accountMetadata
    }
}

public struct UMAccount: Codable {
    public enum CodingKeys: CodingKey {
        case bookmarked
        case annotations
        case read
        case swapIds
    }
    
    let bookmarked: [UMBookmark]
    let annotations: [UMAnnotation]
    let read: [String]
    let swapIds: [UMSwapId]
}

public struct UMBookmark: Codable {
    public enum CodingKeys: CodingKey {
        case txId
        case lastUpdated
        case isBookmarked
    }
    
    let txId: String
    let lastUpdated: Int64
    var isBookmarked: Bool
}

public struct UMAnnotation: Codable {
    public enum CodingKeys: CodingKey {
        case txId
        case content
        case lastUpdated
    }
    
    let txId: String
    let content: String?
    let lastUpdated: Int64
}

public struct UMSwapId: Codable {
    public enum CodingKeys: CodingKey {
        case txId
        case lastUpdated
    }
    
    let txId: String
    let lastUpdated: Int64
}

public extension UserMetadata {
    /// Encrypts user metadata. The structure:
    ///     [Unencrypted data]    `encryption version`
    ///     [Unencrypted data]    `salt`
    ///     [Unencrypted data]    `metadata version`
    ///     [Encrypted data]        `serialized metadata`
    /// This method always produces the latest structure with the latest encryption version.
    static func encryptUserMetadata(_ umData: UserMetadata, account: Account) throws -> Data {
        @Dependency(\.walletStorage) var walletStorage
        
        guard let encryptionKeys = try? walletStorage.exportUserMetadataEncryptionKeys(account),
                let umKey = encryptionKeys.getCached(account: account) else {
            throw UserMetadataStorage.UMError.missingEncryptionKey
        }

        var encryptionVersionData = Data()
        encryptionVersionData.append(contentsOf: Serializer.intToBytes(UserMetadataEncryptionKeys.Constants.version))

        var metadataVersionData = Data()
        metadataVersionData.append(contentsOf: Serializer.intToBytes(UserMetadata.Constants.version))

        // Generate a fresh one-time sub-key for encrypting the user metadata.
        let salt = SymmetricKey(size: SymmetricKeySize.bits256)

        guard let dataForEncryption = try? JSONEncoder().encode(umData) else {
            throw UserMetadataStorage.UMError.serialization
        }

        return try salt.withUnsafeBytes { salt in
            let salt = Data(salt)
            let subKey = umKey.deriveEncryptionKey(salt: salt)
            
            // Encrypt the serialized user metadata.
            // CryptoKit encodes the SealedBox as `nonce || ciphertext || tag`.
            let sealed = try ChaChaPoly.seal(dataForEncryption, using: subKey)
            
            // Prepend the encryption version & salt to the SealedBox so we can re-derive the sub-key.
            
            // unencrypted data
            return encryptionVersionData + salt + metadataVersionData
            // encrypted data
            + sealed.combined
        }
    }
    
    /// Tries to decrypt the data with the structure:
    ///     [Unencrypted data]    `encryption version`
    ///     [Unencrypted data]    `salt`
    ///     [Unencrypted data]    `metadata version`
    ///
    /// - returns: `UserMetadata` if successful and a flag whether migration happened or not
    static func userMetadataFrom(encryptedData: Data, account: Account) throws -> (UserMetadata?, Bool) {
        @Dependency(\.walletStorage) var walletStorage
        
        guard let encryptionKeys = try? walletStorage.exportUserMetadataEncryptionKeys(account),
                let umKey = encryptionKeys.getCached(account: account) else {
            throw UserMetadataStorage.UMError.missingEncryptionKey
        }
        
        var offset = 0
        
        // Deserialize `encryption version`
        let encryptionVersionBytes = try UserMetadata.subdata(of: encryptedData, in: offset..<(offset + UserMetadataStorage.Constants.int64Size))
        offset += UserMetadataStorage.Constants.int64Size
        
        guard let encryptionVersion = UserMetadata.bytesToInt(Array(encryptionVersionBytes)) else {
            return (nil, false)
        }
        
        guard encryptionVersion == UserMetadataEncryptionKeys.Constants.version else {
            throw UserMetadataStorage.UMError.encryptionVersionNotSupported
        }

        let encryptedSubData = try UserMetadata.subdata(of: encryptedData, in: offset..<encryptedData.count)
        
        // Derive the sub-key for decrypting the user metadata.
        let salt = encryptedSubData.prefix(upTo: 32)
        
        let subKeys = umKey.deriveDecryptionKeys(salt: salt)
        
        for subKey in subKeys {
            offset = 32
            
            do {
                // Deserialize `metadata version`
                let metadataVersionBytes = try UserMetadata.subdata(of: encryptedSubData, in: offset..<(offset + UserMetadataStorage.Constants.int64Size))
                offset += UserMetadataStorage.Constants.int64Size
                
                guard let metadataVersion = UserMetadata.bytesToInt(Array(metadataVersionBytes)) else {
                    return (nil, false)
                }
                
                guard metadataVersion == UserMetadata.Constants.version else {
                    // Attempt to migrate
                    switch metadataVersion {
                    case 1:
                        let latestUserMetadata = try UserMetadata.userMetadataV1From(encryptedSubData: encryptedSubData, subKey: subKey)
                        return (latestUserMetadata, true)
                    default:
                        throw UserMetadataStorage.UMError.metadataVersionNotSupported
                    }
                }
                
                // Unseal the encrypted user metadata.
                let sealed = try ChaChaPoly.SealedBox.init(combined: encryptedSubData.suffix(from: 32 +  UserMetadataStorage.Constants.int64Size))
                let data = try ChaChaPoly.open(sealed, using: subKey)
                
                // deserialize the json's data
                let latestUserMetadata = try JSONDecoder().decode(UserMetadata.self, from: data)
                return (latestUserMetadata, false)
            } catch {
                // this key failed to decrypt, try another one
            }
        }

        return (nil, false)
    }

    static func subdata(of data: Data, in range: Range<Data.Index>) throws -> Data {
        guard data.count >= range.upperBound else {
            throw UserMetadataStorage.UMError.subdataRange
        }
        
        return data.subdata(in: range)
    }

    static func bytesToInt(_ bytes: [UInt8]) -> Int? {
        guard bytes.count == UserMetadataStorage.Constants.int64Size else {
            return nil
        }
        
        return bytes.withUnsafeBytes { ptr -> Int? in
            Int.init(exactly: ptr.loadUnaligned(as: Int64.self).bigEndian)
        }
    }
}
