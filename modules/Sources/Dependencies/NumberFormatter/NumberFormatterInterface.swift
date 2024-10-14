//
//  NumberFormatterInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    public var numberFormatter: NumberFormatterClient {
        get { self[NumberFormatterClient.self] }
        set { self[NumberFormatterClient.self] = newValue }
    }
}

@DependencyClient
public struct NumberFormatterClient {
    public var string: (NSDecimalNumber) -> String?
    public var number: (String) -> NSNumber?
    public var convertUSToLocale: (String) -> String?
}
