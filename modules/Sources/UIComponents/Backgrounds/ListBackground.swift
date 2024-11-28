//
//  ListBackground.swift
//  Zashi
//
//  Created by Lukáš Korba on 2024-11-28.
//

import SwiftUI

import Generated

public struct ListBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets())
            .listRowBackground(Asset.Colors.background.color)
            .listRowSeparator(.hidden)
    }
}

extension View {
    public func listBackground() -> some View {
        self.modifier(
            ListBackgroundModifier()
        )
    }
}
