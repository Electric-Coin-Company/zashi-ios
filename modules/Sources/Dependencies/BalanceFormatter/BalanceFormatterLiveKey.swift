//
//  BalanceFormatterLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 14.11.2022.
//

import Foundation
import ComposableArchitecture

extension BalanceFormatterClient: DependencyKey {
    public static let liveValue = Self(
        convert: { ZatoshiStringRepresentation($0, prefixSymbol: $1, format: $2) }
    )
}
