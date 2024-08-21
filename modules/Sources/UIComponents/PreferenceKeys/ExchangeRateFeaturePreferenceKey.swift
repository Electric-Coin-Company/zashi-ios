//
//  ExchangeRateFeaturePreferenceKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 08-12-2024.
//

import SwiftUI

public struct ExchangeRateFeaturePreferenceKey: PreferenceKey {
    public typealias Value = Anchor<CGRect>?

    public static var defaultValue: Value = nil

    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue() ?? value
    }
}
