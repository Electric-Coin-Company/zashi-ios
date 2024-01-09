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

extension View {
    public func applyScreenBackground(withPattern: Bool = false) -> some View {
        self.modifier(
            ScreenBackgroundModifier(
                color: Asset.Colors.secondary.color,
                isPatternOn: withPattern
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
