//
//  ScreenBackground.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI

/// A Vertical LinearGradient that takes an array of Colors and renders them vertically
/// in a centered fashion mostly used as a background for Screen views..
struct ScreenBackground: View {
    var colors: [Color]

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}

extension ScreenBackground {
    static let `default` = ScreenBackground(
        colors: [
            Asset.Colors.ScreenBackground.gradientStart.color,
            Asset.Colors.ScreenBackground.gradientEnd.color
        ]
    )
}
struct ScreenBackgroundModifier: ViewModifier {
    var colors: [Color]

    func body(content: Content) -> some View {
        ZStack {
            ScreenBackground(colors: colors)
                .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

extension View {
    /// Adds a Vertical Linear Gradient with the default Colors of VLinearGradient.
    /// Supports both Light and Dark Mode
    func applyScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.gradientStart.color,
                    Asset.Colors.ScreenBackground.gradientEnd.color
                ]
            )
        )
    }

    func applyErredScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.redGradientStart.color,
                    Asset.Colors.ScreenBackground.redGradientEnd.color
                ]
            )
        )
    }
}

struct ScreenBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
        .applyScreenBackground()
        .preferredColorScheme(.light)
    }
}
