//
//  NeumorphicDesignModifier.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 02/21/22.
//

import SwiftUI

/// Neumorphic design is charasterictical with two shadows (light & dark) around the view
/// Appereance in our case is influenced by two parameters:
/// - Parameters:
///   - colorScheme: The light is using full neumorphic design while dark is limited to soft shadow only
///   - isPressed: When the button is pressed, there are different behaviours for light vs. dark colorScheme
/// This design is mostly used for CircularFrame, not designed for a button (see NeumorphicButtonDesign)
struct NeumorphicDesign: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let isPressed: Bool
    
    init(_ isPressed: Bool) {
        self.isPressed = isPressed
    }
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Asset.Colors.Buttons.neumorphicDarkSide.color,
                radius: 15,
                x: colorScheme == .light && !isPressed ? 10 : -10,
                y: colorScheme == .light && !isPressed ? 10 : 10
            )
            .shadow(
                color: Asset.Colors.Buttons.neumorphicLightSide.color,
                radius: 10,
                x: colorScheme == .light && !isPressed ? -12 : 12,
                y: colorScheme == .light && !isPressed ? -12 : -12
            )
    }
}

/// Neumorphic design is charasterictical with two shadows (light & dark) around the button
/// Appereance in our case is influenced by two parameters:
/// - Parameters:
///   - colorScheme: The light is using full neumorphic design while dark is limited to soft shadow only
///   - isPressed: When the button is pressed, there are different behaviours for light vs. dark colorScheme
/// This design is specifically crafted for buttons. The colors and positions of the shadows are different.
struct NeumorphicButtonDesign: ViewModifier {
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
    func neumorphicDesign(_ isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicDesign(isPressed))
    }

    func neumorphicButtonDesign(_ isPressed: Bool = false) -> some View {
        self.modifier(NeumorphicButtonDesign(isPressed))
    }
}
