//
//  ExchangeRateTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-02-2024.
//

import Combine

extension ExchangeRateClient {
    public static let noOp = Self(
        exchangeRateEventStream: { Empty().eraseToAnyPublisher() },
        refreshExchangeRateUSD: { }
    )
}
