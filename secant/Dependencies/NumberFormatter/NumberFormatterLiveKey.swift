//
//  NumberFormatterLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import Foundation
import ComposableArchitecture

extension NumberFormatterClient: DependencyKey {
    static let liveValue = NumberFormatterClient.live()

    static func live(numberFormatter: NumberFormatter = NumberFormatter.zcashNumberFormatter) -> Self {
        Self(
            string: { numberFormatter.string(from: $0) },
            number: { numberFormatter.number(from: $0) }
        )
    }
}
