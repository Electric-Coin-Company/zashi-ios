//
//  WrappedNumberFormatter.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02.06.2022.
//

import Foundation

extension NumberFormatter {
    static let zcashNumberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}

struct WrappedNumberFormatter {
    let string: (NSDecimalNumber) -> String?
    let number: (String) -> NSNumber?
}

extension WrappedNumberFormatter {
    static func live(numberFormatter: NumberFormatter = NumberFormatter.zcashNumberFormatter) -> Self {
        Self(
            string: { numberFormatter.string(from: $0) },
            number: { numberFormatter.number(from: $0) }
        )
    }
}
