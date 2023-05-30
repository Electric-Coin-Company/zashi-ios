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
            Asset.Colors.ScreenBackground.gradientStart.color,
            Asset.Colors.ScreenBackground.gradientEnd.color
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
                    Asset.Colors.Mfp.background.color,
                    Asset.Colors.Mfp.background.color
                ]
            )
        )
    }

    public func applyErredScreenBackground() -> some View {
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

    public func applySucceededScreenBackground() -> some View {
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
    
    public func applySemiTransparentScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.Mfp.primary.color,
                    Asset.Colors.Mfp.primary.color
                ]
            )
        )
    }

    public func applyDarkScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                colors: [
                    Asset.Colors.ScreenBackground.gradientDarkStart.color,
                    Asset.Colors.ScreenBackground.gradientDarkEnd.color
                ]
            )
        )
    }

    public func applyAmberScreenBackground() -> some View {
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
