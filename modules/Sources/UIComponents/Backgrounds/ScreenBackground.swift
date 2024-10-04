//
//  ScreenBackground.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI
import Generated

public struct ScreenBackgroundModifier: ViewModifier {
    var color: Color

    public func body(content: Content) -> some View {
        ZStack {
            color
                .edgesIgnoringSafeArea(.all)

            content
        }
    }
}

struct ScreenGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    let colors: [Color]
    let darkGradientEndPointY: CGFloat

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: darkGradientEndPointY)
        )
    }
}

struct ScreenGradientBackgroundModifier: ViewModifier {
    let colors: [Color]
    let darkGradientEndPointY: CGFloat

    func body(content: Content) -> some View {
        ZStack {
            ScreenGradientBackground(
                colors: colors,
                darkGradientEndPointY: darkGradientEndPointY
            )
            .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

extension View {
    public func applyScreenBackground() -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                color: Asset.Colors.background.color
            )
        )
    }
    
    public func applyErredScreenBackground() -> some View {
        self.modifier(
            ScreenGradientBackgroundModifier(
                colors: [
                    Design.Utility.WarningYellow._100.color,
                    Design.screenBackground.color
                ],
                darkGradientEndPointY: 0.4
            )
        )
    }
    
    public func applyBrandedScreenBackground() -> some View {
        self.modifier(
            ScreenGradientBackgroundModifier(
                colors: [
                    Design.Utility.Brand._500.color,
                    Design.screenBackground.color
                ],
                darkGradientEndPointY: 0.75
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
