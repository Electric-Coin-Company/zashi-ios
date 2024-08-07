//
//  File.swift
//  
//
//  Created by Lukáš Korba on 22.05.2024.
//

import Foundation
import ZcashLightClientKit

// Both will be defined in the SDK
public enum CurrencyISO4217: String, CaseIterable, Equatable {
    case usd = "USD"
    
    public var code: String {
        rawValue
    }
    
    public var symbol: String {
        switch self {
        case .usd: return "$"
        }
    }
}

public struct CurrencyConversion: Equatable {
    public let iso4217: CurrencyISO4217
    public let ratio: Double
    public let timestamp: TimeInterval
    
    public init(_ iso4217: CurrencyISO4217, ratio: Double, timestamp: TimeInterval) {
        self.iso4217 = iso4217
        self.ratio = ratio
        self.timestamp = timestamp
    }
    
    public func convert(_ zatoshi: Zatoshi) -> Double {
        ratio * (Double(zatoshi.amount) / Double(100_000_000))
    }
    
    public func convert(_ zatoshi: Zatoshi) -> String {
        Decimal(convert(zatoshi)).formatted(.currency(code: iso4217.code))
    }
    
    public func convert(_ currency: Double) -> Zatoshi {
        Zatoshi(Int64((currency / ratio) * Double(100_000_000)))
    }
}
