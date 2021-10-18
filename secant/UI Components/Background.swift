//
//  Background.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/18/21.
//

import SwiftUI

struct Background: View {
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
        .edgesIgnoringSafeArea(.all)
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        Background()
            .preferredColorScheme(.light)
        Background()
            .preferredColorScheme(.dark)
    }
}
