//
//  NumberFormatterLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import Foundation
import ComposableArchitecture

extension NumberFormatter {
    static let zcashNumberFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static let zcashNumberFormatter8FractionDigits: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.minimumFractionDigits = 8
        formatter.maximumIntegerDigits = 8
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}

extension NumberFormatterClient: DependencyKey {
    static let liveValue = NumberFormatterClient.live()

    static func live(numberFormatter: NumberFormatter = NumberFormatter.zcashNumberFormatter) -> Self {
        Self(
            string: { numberFormatter.string(from: $0) },
            number: { numberFormatter.number(from: $0) }
        )
    }
}
