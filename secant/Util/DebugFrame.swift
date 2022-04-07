//
//  DebugFrame.swift
//  secant-testnet
//
//  Created by Adam Stener on 3/25/22.
//

import SwiftUI

struct DebugFrame: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 0.5,
                            dash: [3]
                        )
                    )
            )
            .foregroundColor(color)
    }
}

extension View {
    func debug(_ color: Color) -> some View {
        modifier(DebugFrame(color: color))
    }
}
