//
//  CMCRate.swift
//  Zashi
//
//  Created by Lukáš Korba on 26.11.2025.
//

import Foundation

public struct PriceResponse: Codable {
    public let data: [String: Asset]
}

public struct Asset: Codable {
    public let quote: Quote
}

public struct Quote: Codable {
    public let USD: USDQuote
}

public struct USDQuote: Codable {
    public let price: Double
}
