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
    @Environment(\.colorScheme) var colorScheme

    var colors: [Color]
    var darkGradientEndPointY = 1.0

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: colorScheme == .dark ? darkGradientEndPointY : 1)
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
    var darkGradientEndPointY = 1.0

    func body(content: Content) -> some View {
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
                ],
                darkGradientEndPointY: 0.4
            )
        )
    }

    func applySucceededScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.greenGradientStart.color,
                    Asset.Colors.ScreenBackground.greenGradientEnd.color
                ],
                darkGradientEndPointY: 0.6
            )
        )
    }
    
    func applySemiTransparentScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.semiTransparentGradientStart.color,
                    Asset.Colors.ScreenBackground.semiTransparentGradientEnd.color
                ]
            )
        )
    }

    func applyDarkScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.gradientDarkStart.color,
                    Asset.Colors.ScreenBackground.gradientDarkEnd.color
                ]
            )
        )
    }

    func applyAmberScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.amberGradientStart.color,
                    Asset.Colors.ScreenBackground.amberGradientMiddle.color,
                    Asset.Colors.ScreenBackground.amberGradientEnd.color
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
