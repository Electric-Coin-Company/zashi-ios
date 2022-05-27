//
//  Zatoshi.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 26.05.2022.
//

import Foundation

struct Zatoshi {
    enum Constants {
        static let oneZecInZatoshi: Int64 = 100_000_000
        static let maxZecSupply: Int64 = 21_000_000
        static let maxZatoshi: Int64 = Constants.oneZecInZatoshi * Constants.maxZecSupply
    }
    
    static var decimalHandler = NSDecimalNumberHandler(
        roundingMode: NSDecimalNumber.RoundingMode.bankers,
        scale: 8,
        raiseOnExactness: true,
        raiseOnOverflow: true,
        raiseOnUnderflow: true,
        raiseOnDivideByZero: true
    )
    
    @Clamped(-Constants.maxZatoshi...Constants.maxZatoshi)
    var amount: Int64 = 0

    /// Converts `Zatoshi` to `NSDecimalNumber`
    var decimalValue: NSDecimalNumber {
        NSDecimalNumber(decimal: Decimal(amount) / Decimal(Constants.oneZecInZatoshi))
    }

    /// Converts `Zatoshi` to human readable format, up to 8 fraction digits
    var decimalString: String {
        decimalValue.roundedZec.stringValue
    }

    /// Converts `Decimal` to `Zatoshi`
    static func from(decimal: Decimal) -> Zatoshi {
        let roundedZec = NSDecimalNumber(decimal: decimal).roundedZec
        let zec2zatoshi = Decimal(Constants.oneZecInZatoshi) * roundedZec.decimalValue
        return Zatoshi(amount: NSDecimalNumber(decimal: zec2zatoshi).int64Value)
    }

    /// Converts `String` to `Zatoshi`
    static func from(decimalString: String, formatter: NumberFormatter = NumberFormatter.zcashNumberFormatter) -> Zatoshi? {
        if let number = formatter.number(from: decimalString) {
            return Zatoshi.from(decimal: number.decimalValue)
        }
        
        return nil
    }
    
    static func + (left: Zatoshi, right: Zatoshi) -> Zatoshi {
        Zatoshi(amount: left.amount + right.amount)
    }

    static func - (left: Zatoshi, right: Zatoshi) -> Zatoshi {
        Zatoshi(amount: left.amount - right.amount)
    }
}

extension NSDecimalNumber {
    /// Converts `NSDecimalNumber` to human readable format, up to 8 fraction digits
    var decimalString: String {
        self.rounding(accordingToBehavior: Zatoshi.decimalHandler).stringValue
    }
    
    /// Round the decimal to 8 fraction digits
    var roundedZec: NSDecimalNumber {
        self.rounding(accordingToBehavior: Zatoshi.decimalHandler)
    }
}
