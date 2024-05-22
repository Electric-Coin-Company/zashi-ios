//
//  ExchangeRateTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-02-2024.
//

import ComposableArchitecture
import XCTestDynamicOverlay

import Combine

extension ExchangeRateClient: TestDependencyKey {
    public static let testValue = Self(
        exchangeRateEventStream: XCTUnimplemented("\(Self.self).exchangeRateEventStream", placeholder: Empty().eraseToAnyPublisher()),
        refreshExchangeRateUSD: XCTUnimplemented("\(Self.self).setString")
    )
}
