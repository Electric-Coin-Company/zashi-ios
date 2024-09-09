//
//  ScreenHorizontalPadding.swift
//
//
//  Created by Lukáš Korba on 16.09.2024.
//

import SwiftUI

public struct ScreenHorizontalPaddingModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 24)
    }
}

public extension View {
    func screenHorizontalPadding() -> some View {
        self.modifier(
            ScreenHorizontalPaddingModifier()
        )
    }
}
