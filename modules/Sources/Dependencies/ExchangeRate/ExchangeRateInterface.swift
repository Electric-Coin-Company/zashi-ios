//
//  ExchangeRateInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-02-2024.
//

import ComposableArchitecture
import Combine

import ZcashLightClientKit

extension DependencyValues {
    public var exchangeRate: ExchangeRateClient {
        get { self[ExchangeRateClient.self] }
        set { self[ExchangeRateClient.self] = newValue }
    }
}

public struct ExchangeRateClient {
    public enum EchangeRateEvent: Equatable {
        case value(FiatCurrencyResult?)
        case refreshEnable(FiatCurrencyResult?)
        case stale(FiatCurrencyResult?)
    }

    public let exchangeRateEventStream: () -> AnyPublisher<EchangeRateEvent, Never>
    public var refreshExchangeRateUSD: () -> Void
}
