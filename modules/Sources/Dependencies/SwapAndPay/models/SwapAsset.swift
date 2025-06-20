//
//  SwapAsset.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import SwiftUI
import Generated

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

    public let chain: String
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
