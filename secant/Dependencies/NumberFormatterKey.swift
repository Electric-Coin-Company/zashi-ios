//
//  NumberFormatterKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.11.2022.
//

import ComposableArchitecture

private enum NumberFormatterKey: DependencyKey {
    static let liveValue = WrappedNumberFormatter.live()
}

extension DependencyValues {
    var numberFormatter: WrappedNumberFormatter {
        get { self[NumberFormatterKey.self] }
        set { self[NumberFormatterKey.self] = newValue }
    }
}
