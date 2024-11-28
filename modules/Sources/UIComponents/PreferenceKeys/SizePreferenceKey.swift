//
//  SizePreferenceKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-26..
//

import SwiftUI

public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero
    
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
