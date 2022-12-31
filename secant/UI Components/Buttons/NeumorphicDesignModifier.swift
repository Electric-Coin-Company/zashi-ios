//
//  NeumorphicDesignModifier.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/21/22.
//

import SwiftUI

/// Neumorphic design is characteristical with two shadows (light & dark) around the view
/// Appearance in our case is influenced by two parameters:
/// - Parameters:
///   - colorScheme: The light is using full neumorphic design while dark is limited to soft shadow only
///   - isPressed: When the button is pressed, there are different behaviours for light vs. dark colorScheme
/// This design is mostly used for CircularFrame, not designed for a button (see NeumorphicButtonDesign)
// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate struct Neumorphic: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    let isPressed: Bool
    
    init(_ isPressed: Bool) {
        self.isPressed = isPressed
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Asset.Colors.Onboarding.neumorphicDarkSide.color,
                radius: 15,
                x: colorScheme == .light && !isPressed ? 10 : -10,
                y: 10
            )
            .shadow(
                color: Asset.Colors.Onboarding.neumorphicLightSide.color,
                radius: 10,
                x: colorScheme == .light && !isPressed ? -12 : 12,
                y: -12
            )
    }
}

/// Neumorphic design is characteristical with two shadows (light & dark) around the button
/// Appearance in our case is influenced by two parameters:
/// - Parameters:
///   - colorScheme: The light is using full neumorphic design while dark is limited to soft shadow only
///   - isPressed: When the button is pressed, there are different behaviours for light vs. dark colorScheme
/// This design is specifically crafted for buttons. The colors and positions of the shadows are different.
// swiftlint:disable:next private_over_fileprivate strict_fileprivate
fileprivate struct NeumorphicButton: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let isPressed: Bool
    
    init(_ isPressed: Bool) {
        self.isPressed = isPressed
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Asset.Colors.Buttons.neumorphicButtonDarkSide.color,
                radius: 15,
                x: colorScheme == .light && !isPressed ? 10 : 0,
                y: colorScheme == .light && !isPressed ? 10 : 0
            )
            .shadow(
                color: Asset.Colors.Buttons.neumorphicButtonLightSide.color,
                radius: 10,
                x: colorScheme == .light && !isPressed ? -12 : 0,
                y: colorScheme == .light && !isPressed ? -12 : 0
            )
    }
}

extension View {
    func neumorphic(_ isPressed: Bool = false) -> some View {
        self.modifier(Neumorphic(isPressed))
    }

    func neumorphicButton(_ isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicButton(isPressed))
    }
}
