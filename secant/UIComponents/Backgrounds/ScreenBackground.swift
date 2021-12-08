//
//  ScreenBackground.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI
/**
    A Vertical LinearGradient that takes an array of Colors and renders them vertically in a centered fashion mostly used as a background for Screen views..
*/
struct ScreenBackground: View {
    var colors = [
        Asset.Colors.ScreenBackground.gradientStart.color,
        Asset.Colors.ScreenBackground.gradientEnd.color
    ]
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}

struct ScreenBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ScreenBackground()
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    /**
    Adds a Vertical Linear Gradient with the default Colors of VLinearGradient. Supports both Light and Dark Mode
    */
    func applyScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier()
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
