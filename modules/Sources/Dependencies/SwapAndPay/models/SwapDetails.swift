//
//  SwapDetails.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-23.
//

import Foundation

/// Codable struct for JSON serialization
/// Check the status of a swap.
/// https://docs.near-intents.org/near-intents/integration/distribution-channels/1click-api#get-v0-status
public struct SwapDetails: Codable, Equatable, Hashable {
    public enum Status: Codable, Equatable, Hashable {
        case pending
        case refunded
        case success
    }
    
    public let amountInFormatted: Decimal?
    public let amountInUsd: String?
    public let amountOutFormatted: Decimal?
    public let amountOutUsd: String?
    public let destinationAsset: String?
    public let isSwap: Bool
    public let slippage: Decimal?
    public let status: Status
    public let refundedAmountFormatted: Decimal?
    public let swapRecipient: String?

    init(
        amountInFormatted: Decimal?,
        amountInUsd: String?,
        amountOutFormatted: Decimal?,
        amountOutUsd: String?,
        destinationAsset: String?,
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
        self.destinationAsset = destinationAsset
        self.isSwap = isSwap
        self.slippage = slippage
        self.status = status
        self.refundedAmountFormatted = refundedAmountFormatted
        self.swapRecipient = swapRecipient
    }
}
