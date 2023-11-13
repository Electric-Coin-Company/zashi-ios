//
//  Zatoshi+ZashiSplit.swift
//
//
//  Created by Lukáš Korba on 10.11.2023.
//

import Foundation
import ZcashLightClientKit

public struct BalanceZashiSplit: Equatable {
    public enum PrefixSymbol: Equatable {
        case none
        case minus
        case plus
    }
    
    public let main: String
    public let rest: String
    
    public init(balance: Zatoshi, prefixSymbol: PrefixSymbol = .none) {
        let formatted = balance.decimalZashiFullFormatted()
        
        let rest = String(formatted.suffix(5))
        let mainPart = formatted.dropLast(5)
        var symbol = ""
        
        switch prefixSymbol {
        case .minus: symbol = "-"
        case .plus: symbol = "+"
        default: break
        }
        
        self.main = "\(symbol)\(mainPart)"
        self.rest = "\(rest)"
    }
}
