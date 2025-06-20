//
//  SwapSubmitHash.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-06-19.
//

/// Codable struct for JSON serialization
/// Check the status of Near's Swap
/// https://docs.near-intents.org/near-intents/integration/distribution-channels/1click-api#get-v0-status
struct SwapSubmitHash: Codable, Equatable, Hashable {
    let txHash: String
    let depositAddress: String
}
