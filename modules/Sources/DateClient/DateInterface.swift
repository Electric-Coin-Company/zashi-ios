//
//  DateClient.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2023.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    public var date: DateClient {
        get { self[DateClient.self] }
        set { self[DateClient.self] = newValue }
    }
}

public struct DateClient {
    public let now: () -> Date
}
