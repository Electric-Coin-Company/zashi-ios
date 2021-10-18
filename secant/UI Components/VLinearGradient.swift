//
//  Background.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI
/**
    A Vertical LinearGradient that takes an array of Colors and renders them vertically in a centered fashion.
*/
struct VLinearGradient: View {
    var colors = [
        Asset.Colors.Background.linearGradientStart.color,
        Asset.Colors.Background.linearGradientEnd.color
    ]
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}

struct VLinearGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            VLinearGradient()
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    /**
    Adds a Vertical Linear Gradient with the default Colors of VLinearGradient. Supports both Light and Dark Mode
    */
    func linearGradientBackground() -> some View {
        self.modifier(
            VLinearGradientBackgroundModifier()
        )
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
        .linearGradientBackground()
        .preferredColorScheme(.light)
    }
}
