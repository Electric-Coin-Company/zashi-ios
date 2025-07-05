//
//  SwapAsset.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import Generated

/// Codable struct for JSON serialization
/// Supported Near tokens 
/// https://docs.near-intents.org/near-intents/integration/distribution-channels/1click-api#get-v0-tokens
public struct SwapAsset: Equatable, Codable, Identifiable, Hashable {
    public var id: String {
        "\(chain).\(token)".lowercased()
    }
    
    public var chainName: String {
        switch chain.lowercased() {
        case "arb": return "Arbitrum"
        case "base": return "Base"
        case "bera": return "Bera"
        case "btc": return "Bitcoin"
        case "eth": return "Ethereum"
        case "gnosis": return "Gnosis"
        case "near": return "Near"
        case "sol": return "Solana"
        case "tron": return "Tron"
        case "xrp": return "Ripple"
        case "zec": return "Zcash"
        case "doge": return "Doge"
        default: return chain
        }
    }
    
    public var tokenName: String {
        switch token.lowercased() {
        case "btc": return "Bitcoin"
        case "eth": return "Ethereum"
        case "near": return "Near"
        case "sol": return "Solana"
        case "tron": return "Tron"
        case "xrp": return "Ripple"
        case "zec": return "Zcash"
        default: return token
        }
    }

    public var chainIcon: Image {
        guard let icon = UIImage(named: chain.lowercased()) else {
            return Asset.Assets.Tickers.none.image
        }

        return Image(uiImage: icon)
    }

    public var tokenIcon: Image {
        guard let icon = UIImage(named: token.lowercased()) else {
            return Asset.Assets.Tickers.none.image
        }

        return Image(uiImage: icon)
    }

    public var chain: String
    public let token: String
    public let assetId: String
    public let usdPrice: Decimal
    public let decimals: Int
    
    init(
        chain: String,
        token: String,
        assetId: String,
        usdPrice: Decimal,
        decimals: Int
    ) {
        self.chain = chain
        self.token = token
        self.assetId = assetId
        self.usdPrice = usdPrice
        self.decimals = decimals
    }
}

public extension SwapAsset {
    static func hardcodedChains() -> [SwapAsset] {
        var template = SwapAsset(chain: "", token: "", assetId: "", usdPrice: 0, decimals: 0)
        
        let arb = template; template.chain = "arb"
        let base = template; template.chain = "base"
        let bera = template; template.chain = "bera"
        let btc = template; template.chain = "btc"
        let eth = template; template.chain = "eth"
        let gnosis = template; template.chain = "gnosis"
        let near = template; template.chain = "near"
        let sol = template; template.chain = "sol"
        let tron = template; template.chain = "tron"
        let xrp = template; template.chain = "xrp"
        let doge = template; template.chain = "doge"

        return [
            arb, base, bera, btc, eth, gnosis, near, sol, tron, xrp, doge
        ]
    }
}
