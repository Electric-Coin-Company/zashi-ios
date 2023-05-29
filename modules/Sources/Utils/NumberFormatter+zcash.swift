//
//  NumberFormatter+zcash.swift
//  
//
//  Created by Lukáš Korba on 29.05.2023.
//

import Foundation

extension NumberFormatter {
    public static let zcashNumberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    public static let zcashNumberFormatter8FractionDigits: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.minimumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}
