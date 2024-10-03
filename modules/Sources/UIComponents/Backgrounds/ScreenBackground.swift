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
    let isPatternOn: Bool

    public func body(content: Content) -> some View {
        ZStack {
            color
                .edgesIgnoringSafeArea(.all)
            
            if isPatternOn {
                Asset.Assets.gridTile.image
                    .resizable(resizingMode: .tile)
                    .edgesIgnoringSafeArea(.all)
            }

            content
        }
    }
}

struct ScreenGradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var colors: [Color]
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 0.4)
        )
    }
}

struct ScreenGradientBackgroundModifier: ViewModifier {
    var colors: [Color]
    var darkGradientEndPointY = 1.0

    func body(content: Content) -> some View {
        ZStack {
            ScreenGradientBackground(
                colors: colors
            )
            .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

extension View {
    public func applyScreenBackground(withPattern: Bool = false) -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                color: Asset.Colors.background.color,
                isPatternOn: withPattern
            )
        )
    }
    
    public func applyErredScreenBackground() -> some View {
        self.modifier(
            ScreenGradientBackgroundModifier(
                colors: [
                    Design.Utility.WarningYellow._100.color,
                    Design.screenBackground.color
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
