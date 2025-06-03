//
//  SwapQuote.swift
//  Zashi
//
//  Created by Lukáš Korba on 30.05.2025.
//

struct AppFee: Codable, Equatable, Hashable {
    let recipient: String
    let fee: Int
}

struct SwapQuote: Codable, Equatable, Hashable {
    let dry: Bool
    let swapType: String
    let slippageTolerance: Int
    let originAsset: String
    let depositType: String
    let destinationAsset: String
    let amount: String
    let refundTo: String
    let refundType: String
    let recipient: String
    let recipientType: String
    let deadline: String
    let referral: String
    let quoteWaitingTimeMs: Int
    let appFees: [AppFee]
}
