//
//  ZatoshiStringRepresentation.swift
//
//
//  Created by Lukáš Korba on 10.11.2023.
//

import Foundation
import ZcashLightClientKit
import ComposableArchitecture

import Generated
import Utils

public struct ZatoshiStringRepresentation: Equatable {
    public enum PrefixSymbol: Equatable {
        case none
        case minus
        case plus
    }
    
    public enum Format: Equatable {
        case abbreviated
        case expanded
    }

    public let mostSignificantDigits: String
    public let leastSignificantDigits: String
    public let feeFormat = ZatoshiStringRepresentation.feeFormat

    public init(
        _ zatoshi: Zatoshi,
        prefixSymbol: PrefixSymbol = .none,
        format: Format = .abbreviated
    ) {
        var symbol = ""
        
        switch prefixSymbol {
        case .minus: symbol = "-"
        case .plus: symbol = "+"
        default: break
        }
        
        // 0 zatoshi case
        if zatoshi.amount == 0 {
            self.mostSignificantDigits = "\(symbol)\(Zatoshi(0).decimalZashiFormatted())"
            self.leastSignificantDigits = ""
        } else if zatoshi.amount < 100_000 && format == .abbreviated {
            // 0 for most significant but non-0 for least ones
            self.mostSignificantDigits = "\(symbol)\(Zatoshi(0).decimalZashiFormatted())..."
            self.leastSignificantDigits = ""
        } else {
            if format == .expanded {
                let formatted = zatoshi.decimalZashiFullFormatted()
                
                let leastSignificantDigits = String(formatted.suffix(5))
                let mostSignificantDigits = formatted.dropLast(5)
                
                var leastTrimmed = ""
                var useTheRest = false
                
                for char in leastSignificantDigits.reversed() {
                    if char != "0" {
                        useTheRest = true
                    }
                    
                    if useTheRest {
                        leastTrimmed += String(char)
                    }
                }
                
                leastTrimmed = String(leastTrimmed.reversed())
                
                self.mostSignificantDigits = "\(symbol)\(mostSignificantDigits)"
                self.leastSignificantDigits = "\(leastTrimmed)"
            } else {
                let formatted = zatoshi.decimalZashiFormatted()
                                
                self.mostSignificantDigits = "\(symbol)\(formatted)"
                self.leastSignificantDigits = ""
            }
        }
    }
}

extension ZatoshiStringRepresentation {
    static let placeholder = Self(Zatoshi(123_456_000))
}

extension ZatoshiStringRepresentation {
    public static var feeFormat: String { L10n.General.fee(Zatoshi(100_000).decimalZashiFormatted()) }
}
