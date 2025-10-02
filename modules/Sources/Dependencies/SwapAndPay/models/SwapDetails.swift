//
//  SwapDetails.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-23.
//

import Foundation
import Models

/// Codable struct for JSON serialization
/// Check the status of a swap.
/// https://docs.near-intents.org/near-intents/integration/distribution-channels/1click-api#get-v0-status
public struct SwapDetails: Codable, Equatable, Hashable {
    public enum Status: Codable, Equatable, Hashable {
        case failed
        case pending
        case pendingDeposit
        case processing
        case refunded
        case success
        case expired

        public var rawName: String {
            switch self {
            case .failed: return SwapConstants.failed
            case .pending: return SwapConstants.pendingDeposit
            case .pendingDeposit: return SwapConstants.pendingDeposit
            case .processing: return SwapConstants.processing
            case .refunded: return SwapConstants.refunded
            case .success: return SwapConstants.success
            case .expired: return SwapConstants.expired
            }
        }
    }
    
    public let amountInFormatted: Decimal?
    public let amountInUsd: String?
    public let amountOutFormatted: Decimal?
    public let amountOutUsd: String?
    public let fromAsset: String?
    public let toAsset: String?
    public let isSwap: Bool
    public let slippage: Decimal?
    public let status: Status
    public let refundedAmountFormatted: Decimal?
    public let swapRecipient: String?

    public var isSwapToZec: Bool {
        toAsset == "nep141:zec.omft.near"
    }
    
    init(
        amountInFormatted: Decimal?,
        amountInUsd: String?,
        amountOutFormatted: Decimal?,
        amountOutUsd: String?,
        fromAsset: String?,
        toAsset: String?,
        isSwap: Bool,
        slippage: Decimal?,
        status: Status,
        refundedAmountFormatted: Decimal?,
        swapRecipient: String?
    ) {
        self.amountInFormatted = amountInFormatted
        self.amountInUsd = amountInUsd
        self.amountOutFormatted = amountOutFormatted
        self.amountOutUsd = amountOutUsd
        self.fromAsset = fromAsset
        self.toAsset = toAsset
        self.isSwap = isSwap
        self.slippage = slippage
        self.status = status
        self.refundedAmountFormatted = refundedAmountFormatted
        self.swapRecipient = swapRecipient
    }
}
