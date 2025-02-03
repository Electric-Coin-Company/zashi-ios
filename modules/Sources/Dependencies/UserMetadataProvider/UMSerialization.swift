//
//  UMSerialization.swift
//  modules
//
//  Created by Lukáš Korba on 03.02.2025.
//

import Foundation

public struct UserMetadata: Codable {
    public enum CodingKeys: CodingKey {
        case version
        case lastUpdated
        case accounts
    }
    
    let version: Int
    let lastUpdated: TimeInterval
    let accounts: [UMAccount]
}

public struct UMAccount: Codable {
    public enum CodingKeys: CodingKey {
        case bookmarked
        case annotations
        case read
    }
    
    let bookmarked: [UMBookmark]
    let annotations: [UMAnnotation]
    let read: [UMRead]
}

public struct UMBookmark: Codable {
    public enum CodingKeys: CodingKey {
        case txid
        case lastUpdated
    }
    
    let txid: String
    let lastUpdated: TimeInterval
}

public struct UMAnnotation: Codable {
    public enum CodingKeys: CodingKey {
        case txid
        case lastUpdated
        case text
    }
    
    let txid: String
    let lastUpdated: TimeInterval
    let text: String?
}

public struct UMRead: Codable {
    public enum CodingKeys: CodingKey {
        case txid
        case lastUpdated
        case value
    }
    
    let txid: String
    let lastUpdated: TimeInterval
    let value: Bool
}
