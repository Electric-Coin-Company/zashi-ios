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
        case .mainnet:  return 1
        case .testnet:  return 0
        }
    }
}

extension NetworkType {
    static func forChainName(_ chainame: String) -> NetworkType? {
        switch chainame {
        case "test":    return .testnet
        case "main":    return .mainnet
        default:        return nil
        }
    }
}

public enum ZcashNetworkBuilder {
    public static func network(for networkType: NetworkType) -> ZcashNetwork {
        switch networkType {
        case .mainnet:  return ZcashMainnet()
        case .testnet:  return ZcashTestnet()
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
Constants of ZcashLightClientKit.
*/
public enum ZcashSDK {
    /**
    The number of zatoshi that equal 1 ZEC.
    */
    public static var zatoshiPerZEC: BlockHeight = 100_000_000

    /**
    The theoretical maximum number of blocks in a reorg, due to other bottlenecks in the protocol design.
    */
    public static var maxReorgSize = 100

    /**
    The amount of blocks ahead of the current height where new transactions are set to expire. This value is controlled by the rust backend but it is helpful to know what it is set to and should be kept in sync.
    */
    public static var expiryOffset = 20

    //
    // Defaults
    //
    /**
    Default size of batches of blocks to request from the compact block service.
    */
    public static var defaultBatchSize = 100

    /**
    Default amount of time, in in seconds, to poll for new blocks. Typically, this should be about half the average block time.
    */
    public static var defaultPollInterval: TimeInterval = 20

    /**
    Default attempts at retrying.
    */
    public static var defaultRetrie: Int = 5

    /**
    The default maximum amount of time to wait during retry backoff intervals. Failed loops will never wait longer than this before retrying.
    */
    public static var defaultMaxBackoffInterval: TimeInterval = 600

    /**
    Default number of blocks to rewind when a chain reorg is detected. This should be large enough to recover from the reorg but smaller than the theoretical max reorg size of 100.
    */
    public static var defaultRewindDistance: Int = 10

    /**
    The number of blocks to allow before considering our data to be stale. This usually helps with what to do when returning from the background and is exposed via the Synchronizer's isStale function.
    */
    public static var defaultStaleTolerance: Int = 10

    /**
    Default Name for LibRustZcash data.db
    */
    public static var defaultDataDbName = "data.db"

    /**
    Default Name for Compact Block caches db
    */
    public static var defaultCachesDbName = "caches.db"

    /**
    Default name for pending transactions db
    */
    public static var defaultPendingDbName = "pending.db"

    /**
    File name for the sapling spend params
    */
    public static var spendParamFileName = "sapling-spend.params"

    /**
    File name for the sapling output params
    */
    public static var outputParamFileName = "sapling-output.params"

    /**
    The Url that is used by default in zcashd. We'll want to make this externally configurable, rather than baking it into the SDK but this will do for now, since we're using a cloudfront URL that already redirects.
    */
    public static var cloudParamDirURL = "https://z.cash/downloads/"
}

public protocol NetworkConstants {
    /**
    The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any block prior to this height, at all.
    */
    static var saplingActivationHeight: BlockHeight { get }

    /**
    Default Name for LibRustZcash data.db
    */
    static var defaultDataDbName: String { get }

    /**
    Default Name for Compact Block caches db
    */
    static var defaultCachesDbName: String { get }

    /**
    Default name for pending transactions db
    */
    static var defaultPendingDbName: String { get }

    static var defaultDbNamePrefix: String { get }

    /**
    Fixed height where the SDK considers that the ZIP-321 was deployed. This is a workaround for librustzcash not figuring out the tx fee from the tx itself.
    */
    static var feeChangeHeight: BlockHeight { get }

    static func defaultFee(for height: BlockHeight) -> Int64
}

public extension NetworkConstants {
    static func defaultFee(for height: BlockHeight = BlockHeight.max) -> Int64 {
        guard  height >= feeChangeHeight else { return 10_000 }

        return 1_000
    }
}

public class ZcashSDKMainnetConstants: NetworkConstants {
    /**
    The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks prior to this height, at all.
    */
    public static var saplingActivationHeight: BlockHeight = 419_200

    /**
    Default Name for LibRustZcash data.db
    */
    public static var defaultDataDbName = "data.db"

    /**
    Default Name for Compact Block caches db
    */
    public static var defaultCachesDbName = "caches.db"

    /**
    Default name for pending transactions db
    */
    public static var defaultPendingDbName = "pending.db"

    public static var defaultDbNamePrefix = "ZcashSdk_mainnet_"

    public static var feeChangeHeight: BlockHeight = 1_077_550

    private init() {}
}

public class ZcashSDKTestnetConstants: NetworkConstants {
    /**
    The height of the first sapling block. When it comes to shielded transactions, we do not need to consider any blocks prior to this height, at all.
    */
    public static var saplingActivationHeight: BlockHeight = 280_000

    /**
    Default Name for LibRustZcash data.db
    */
    public static var defaultDataDbName = "data.db"

    /**
    Default Name for Compact Block caches db
    */
    public static var defaultCachesDbName = "caches.db"

    /**
    Default name for pending transactions db
    */
    public static var defaultPendingDbName = "pending.db"

    public static var defaultDbNamePrefix = "ZcashSdk_testnet_"

    /**
    Estimated height where wallets are supposed to change the fee
    */
    public static var feeChangeHeight: BlockHeight = 1_028_500

    private init() {}
}
