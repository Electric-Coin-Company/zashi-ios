//
//  ScreenBackground.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI
import Generated

/// A Vertical LinearGradient that takes an array of Colors and renders them vertically
/// in a centered fashion mostly used as a background for Screen views..
public struct ScreenBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var colors: [Color]
    var darkGradientEndPointY = 1.0

    public var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: colorScheme == .dark ? darkGradientEndPointY : 1)
        )
    }
}

extension ScreenBackground {
    public static let `default` = ScreenBackground(
        colors: [
            Asset.Colors.primary.color,
            Asset.Colors.primary.color
        ]
    )
}

public struct ScreenBackgroundModifier: ViewModifier {
    var colors: [Color]
    var darkGradientEndPointY = 1.0

    public func body(content: Content) -> some View {
        ZStack {
            ScreenBackground(
                colors: colors,
                darkGradientEndPointY: darkGradientEndPointY
            )
            .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

extension View {
    /// Adds a Vertical Linear Gradient with the default Colors of VLinearGradient.
    /// Supports both Light and Dark Mode
    public func applyScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    .white,
                    .white
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
