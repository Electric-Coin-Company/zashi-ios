//
//  BlueChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/25/21.
//

import SwiftUI

struct ColoredChip: View {
    var word: String
    var color = Asset.Colors.Buttons.activeButton.color
    var body: some View {
        Text(word)
            .font(.custom(FontFamily.Rubik.regular.name, size: 15))
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 30,
                maxHeight: .infinity
            )
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Asset.Colors.Text.activeButtonText.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}

struct ColoredChip_Previews: PreviewProvider {
    static var previews: some View {
        ColoredChip(word: "negative")
            .frame(width: 115)
            .applyScreenBackground()
    }
}
