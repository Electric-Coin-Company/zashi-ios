//
//  BirthdayPreferenceKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 10-30-2024.
//

import SwiftUI

public struct BirthdayPreferenceKey: PreferenceKey {
    public typealias Value = Anchor<CGRect>?

    public static var defaultValue: Value = nil

    public static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue() ?? value
    }
}
