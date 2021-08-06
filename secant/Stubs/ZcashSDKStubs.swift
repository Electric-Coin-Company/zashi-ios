//
//  ZcashSDKStubs.swift
//  secant
//
//  Created by Francisco Gindre on 8/6/21.
//

import Foundation
public typealias BlockHeight = Int
public protocol ZcashNetwork {
    var networkType: NetworkType { get }
    var constants: NetworkConstants.Type { get }
}

public enum NetworkType {
    case mainnet
    case testnet
    
    var networkId: UInt32 {
        switch self {
        case .mainnet:
            return 1
        case .testnet:
            return 0
        }
    }
}

extension NetworkType {
    static func forChainName(_ chainame: String) -> NetworkType? {
        switch chainame {
        case "test":
            return .testnet
        case "main":
            return .mainnet
        default:
            return nil
        }
    }
}

public class ZcashNetworkBuilder {
    public static func network(for networkType: NetworkType) -> ZcashNetwork {
        switch networkType {
        case .mainnet:
            return ZcashMainnet()
        case .testnet:
            return ZcashTestnet()
        }
    }
}

class ZcashTestnet: ZcashNetwork {
    var networkType: NetworkType = .testnet
    var constants: NetworkConstants.Type = ZcashSDKTestnetConstants.self
}

class ZcashMainnet: ZcashNetwork {
    var networkType: NetworkType = .mainnet
    var constants: NetworkConstants.Type = ZcashSDKMainnetConstants.self
}

/**
 Constants of ZcashLightClientKit. this constants don't
 */
public class ZcashSDK {
    
    /**
     The number of zatoshi that equal 1 ZEC.
     */
    public static var ZATOSHI_PER_ZEC: BlockHeight = 100_000_000
    
    /**
     The theoretical maximum number of blocks in a reorg, due to other bottlenecks in the protocol design.
     */
    public static var MAX_REORG_SIZE = 100
    /**
     The amount of blocks ahead of the current height where new transactions are set to expire. This value is controlled
     by the rust backend but it is helpful to know what it is set to and should be kept in sync.
     */
    public static var EXPIRY_OFFSET = 20
    //
    // Defaults
    //
    /**
     Default size of batches of blocks to request from the compact block service.
     */
    public static var DEFAULT_BATCH_SIZE = 100
    /**
     Default amount of time, in in seconds, to poll for new blocks. Typically, this should be about half the average
     block time.
     */
    public static var DEFAULT_POLL_INTERVAL: TimeInterval = 20
    /**
     Default attempts at retrying.
     */
    public static var DEFAULT_RETRIES: Int = 5
    /**
     The default maximum amount of time to wait during retry backoff intervals. Failed loops will never wait longer than
     this before retyring.
     */
    public static var DEFAULT_MAX_BACKOFF_INTERVAL: TimeInterval = 600
    /**
     Default number of blocks to rewind when a chain reorg is detected. This should be large enough to recover from the
     reorg but smaller than the theoretical max reorg size of 100.
     */
    public static var DEFAULT_REWIND_DISTANCE: Int = 10
    /**
     The number of blocks to allow before considering our data to be stale. This usually helps with what to do when
     returning from the background and is exposed via the Synchronizer's isStale function.
     */
    public static var DEFAULT_STALE_TOLERANCE: Int = 10
    
    /**
     Default Name for LibRustZcash data.db
     */
    public static var DEFAULT_DATA_DB_NAME = "data.db"
    
    /**
     Default Name for Compact Block caches db
     */
    public static var DEFAULT_CACHES_DB_NAME = "caches.db"
    /**
     Default name for pending transactions db
     */
    public static var DEFAULT_PENDING_DB_NAME = "pending.db"
    
    /**
     File name for the sapling spend params
     */
    public static var SPEND_PARAM_FILE_NAME = "sapling-spend.params"
    /**
     File name for the sapling output params
     */
    public static var OUTPUT_PARAM_FILE_NAME = "sapling-output.params"
    /**
     The Url that is used by default in zcashd.
     We'll want to make this externally configurable, rather than baking it into the SDK but
     this will do for now, since we're using a cloudfront URL that already redirects.
     */
    public static var CLOUD_PARAM_DIR_URL = "https://z.cash/downloads/"
}

public protocol NetworkConstants {
    
    /**
     The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
     prior to this height, at all.
     */
    static var SAPLING_ACTIVATION_HEIGHT: BlockHeight { get }
    
    /**
     Default Name for LibRustZcash data.db
     */
    static var DEFAULT_DATA_DB_NAME: String { get }
    /**
     Default Name for Compact Block caches db
     */
    static var DEFAULT_CACHES_DB_NAME: String { get }
    /**
     Default name for pending transactions db
     */
    static var DEFAULT_PENDING_DB_NAME: String { get }
    static var DEFAULT_DB_NAME_PREFIX: String { get }
   
    /**
     fixed height where the SDK considers that the ZIP-321 was deployed. This is a workaround
     for librustzcash not figuring out the tx fee from the tx itself.
     */
    static var FEE_CHANGE_HEIGHT: BlockHeight { get }
    
    static func defaultFee(for height: BlockHeight) -> Int64
    
}

public extension NetworkConstants {
    
    static func defaultFee(for height: BlockHeight = BlockHeight.max) -> Int64 {
        guard  height >= FEE_CHANGE_HEIGHT else { return 10_000 }
        
        return 1_000
    }
}

public class ZcashSDKMainnetConstants: NetworkConstants {
    
    private init() {}
    
    /**
     The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
     prior to this height, at all.
     */
    public static var SAPLING_ACTIVATION_HEIGHT: BlockHeight = 419_200
    
    /**
     Default Name for LibRustZcash data.db
     */
    public static var DEFAULT_DATA_DB_NAME = "data.db"
    /**
     Default Name for Compact Block caches db
     */
    public static var DEFAULT_CACHES_DB_NAME = "caches.db"
    /**
     Default name for pending transactions db
     */
    public static var DEFAULT_PENDING_DB_NAME = "pending.db"
    
    public static var DEFAULT_DB_NAME_PREFIX = "ZcashSdk_mainnet_"
    
    public static var FEE_CHANGE_HEIGHT: BlockHeight = 1_077_550
}

public class ZcashSDKTestnetConstants: NetworkConstants {
    private init() {}
   
    /**
     The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks
     prior to this height, at all.
     */
    public static var SAPLING_ACTIVATION_HEIGHT: BlockHeight = 280_000
   
    /**
     Default Name for LibRustZcash data.db
     */
    public static var DEFAULT_DATA_DB_NAME = "data.db"
    /**
     Default Name for Compact Block caches db
     */
    public static var DEFAULT_CACHES_DB_NAME = "caches.db"
    /**
     Default name for pending transactions db
     */
    public static var DEFAULT_PENDING_DB_NAME = "pending.db"
    
    public static var DEFAULT_DB_NAME_PREFIX = "ZcashSdk_testnet_"
    
    /**
     Estimated height where wallets are supposed to change the fee
     */
    public static var FEE_CHANGE_HEIGHT: BlockHeight = 1_028_500
    
}
