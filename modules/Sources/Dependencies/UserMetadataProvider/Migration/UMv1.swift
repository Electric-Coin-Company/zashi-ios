//
//  UMv1.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-23.
//

import Foundation
import CryptoKit

public struct UserMetadataV1: Codable {
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
    let accountMetadata: UMAccountV1
    
    public init(version: Int, lastUpdated: Int64, accountMetadata: UMAccountV1) {
        self.version = version
        self.lastUpdated = lastUpdated
        self.accountMetadata = accountMetadata
    }
}

public struct UMAccountV1: Codable {
    public enum CodingKeys: CodingKey {
        case bookmarked
        case annotations
        case read
    }
    
    let bookmarked: [UMBookmark]
    let annotations: [UMAnnotation]
    let read: [String]
}

extension UserMetadata {
    static func v1ToLatest(_ userMetadataV1: UserMetadataV1) throws -> UserMetadata {
        UserMetadata(
            version: UserMetadata.Constants.version,
            lastUpdated: userMetadataV1.lastUpdated,
            accountMetadata:
                UMAccount(
                    bookmarked: userMetadataV1.accountMetadata.bookmarked,
                    annotations: userMetadataV1.accountMetadata.annotations,
                    read: userMetadataV1.accountMetadata.read,
                    swapIds: []
                )
        )
    }
    
    static func userMetadataV1From(encryptedSubData: Data, subKey: SymmetricKey) throws -> UserMetadata? {
        // Unseal the encrypted user metadata.
        let sealed = try ChaChaPoly.SealedBox.init(combined: encryptedSubData.suffix(from: 32 +  UserMetadataStorage.Constants.int64Size))
        let data = try ChaChaPoly.open(sealed, using: subKey)
        
        // deserialize the json's data
        let userMetadataV1 = try JSONDecoder().decode(UserMetadataV1.self, from: data)
        
        return try UserMetadata.v1ToLatest(userMetadataV1)
    }
}
