//
//  NumberFormatterLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 14.11.2022.
//

import Foundation
import ComposableArchitecture
import Utils

extension NumberFormatterClient: DependencyKey {
    public static let liveValue = NumberFormatterClient.live()

    public static func live(numberFormatter: NumberFormatter = NumberFormatter.zcashNumberFormatter) -> Self {
        Self(
            string: {
                numberFormatter.string(from: $0)
            },
            number: {
                numberFormatter.number(from: $0)
            },
            convertUSToLocale: {
                let number = NumberFormatter.zcashUSNumberFormatter.number(from: $0)
                let decimalNumber = NSDecimalNumber(decimal: number?.decimalValue ?? 0)
                return numberFormatter.string(from: decimalNumber)
            }
        )
    }
}
