//
//  BalanceFormatterInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    public var balanceFormatter: BalanceFormatterClient {
        get { self[BalanceFormatterClient.self] }
        set { self[BalanceFormatterClient.self] = newValue }
    }
}

public struct BalanceFormatterClient {
    public var convert: (
        Zatoshi,
        ZatoshiStringRepresentation.PrefixSymbol,
        ZatoshiStringRepresentation.Format
    ) -> ZatoshiStringRepresentation
}
