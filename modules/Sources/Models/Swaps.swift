//
//  Swaps.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-09-25.
//

import Foundation

public enum SwapConstants {
    public static let pendingDeposit = "PENDING_DEPOSIT"
    public static let incompleteDeposit = "INCOMPLETE_DEPOSIT"
    public static let processing = "PROCESSING"
    public static let success = "SUCCESS"
    public static let failed = "FAILED"
    public static let refunded = "REFUNDED"
    public static let expired = "EXPIRED"
    
    public static let zecAssetIdOnNear = "near.zec.zec"
}

public struct UserMetadata: Codable {
    public enum Constants {
        public static let version = 3
    }
    
    public enum CodingKeys: CodingKey {
        case version
        case lastUpdated
        case accountMetadata
    }
    
    public let version: Int
    public let lastUpdated: Int64
    public let accountMetadata: UMAccount
    
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
        case swaps
    }
    
    public let bookmarked: [UMBookmark]
    public let annotations: [UMAnnotation]
    public let read: [String]
    public let swaps: UMSwaps
    
    public init(bookmarked: [UMBookmark], annotations: [UMAnnotation], read: [String], swaps: UMSwaps) {
        self.bookmarked = bookmarked
        self.annotations = annotations
        self.read = read
        self.swaps = swaps
    }
}

public struct UMBookmark: Codable {
    public enum CodingKeys: CodingKey {
        case txId
        case lastUpdated
        case isBookmarked
    }
    
    public let txId: String
    public let lastUpdated: Int64
    public var isBookmarked: Bool
    
    public init(txId: String, lastUpdated: Int64, isBookmarked: Bool) {
        self.txId = txId
        self.lastUpdated = lastUpdated
        self.isBookmarked = isBookmarked
    }
}

public struct UMAnnotation: Codable {
    public enum CodingKeys: CodingKey {
        case txId
        case content
        case lastUpdated
    }
    
    public let txId: String
    public let content: String?
    public let lastUpdated: Int64
    
    public init(txId: String, content: String?, lastUpdated: Int64) {
        self.txId = txId
        self.content = content
        self.lastUpdated = lastUpdated
    }
}

public struct UMSwaps: Codable {
    public enum CodingKeys: CodingKey {
        case lastUsedAssetHistory
        case swapIds
        case lastUpdated
    }

    /// Collection of all swaps that happened in the wallet
    public let swapIds: [UMSwapId]
    /// Collection of 10 last SwapAssets
    public let lastUsedAssetHistory: [String]
    public let lastUpdated: Int64
    
    public init(swapIds: [UMSwapId], lastUsedAssetHistory: [String], lastUpdated: Int64) {
        self.swapIds = swapIds
        self.lastUsedAssetHistory = lastUsedAssetHistory
        self.lastUpdated = lastUpdated
    }
}

public struct UMSwapId: Codable, Equatable {
    public enum CodingKeys: CodingKey {
        case depositAddress
        case provider
        case totalFees
        case totalUSDFees
        case lastUpdated
        case fromAsset
        case toAsset
        case exactInput
        case status
        case amountOutFormatted
    }
    
    public enum SwapStatus: Equatable {
        case completed
        case expired
        case failed
        case pending
        case refunded
    }
    
    public var depositAddress: String
    public var provider: String
    public var totalFees: Int64
    public var totalUSDFees: String
    public var lastUpdated: Int64
    public var fromAsset: String
    public var toAsset: String
    public var exactInput: Bool
    public var status: String
    public var amountOutFormatted: String

    public var swapStatus: SwapStatus {
        if status == SwapConstants.failed {
            return .failed
        }

        if status == SwapConstants.refunded {
            return .refunded
        }

        if status == SwapConstants.expired {
            return .expired
        }

        if status == SwapConstants.success {
            return .completed
        }

        if status == SwapConstants.pendingDeposit || status == SwapConstants.processing || status == SwapConstants.incompleteDeposit {
            return .pending
        }
        
        return .pending
    }
    
    public init(
        depositAddress: String,
        provider: String,
        totalFees: Int64,
        totalUSDFees: String,
        lastUpdated: Int64,
        fromAsset: String,
        toAsset: String,
        exactInput: Bool,
        status: String,
        amountOutFormatted: String
    ) {
        self.depositAddress = depositAddress
        self.provider = provider
        self.totalFees = totalFees
        self.totalUSDFees = totalUSDFees
        self.lastUpdated = lastUpdated
        self.fromAsset = fromAsset
        self.toAsset = toAsset
        self.exactInput = exactInput
        self.status = status
        self.amountOutFormatted = amountOutFormatted
    }
}
