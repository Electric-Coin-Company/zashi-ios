//
//  BlueChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/25/21.
//

import SwiftUI

struct BlueChip: View {
    var word: String
    var body: some View {
        Text(word)
            .font(FontFamily.Rubik.regular.textStyle(.body))
            .frame(
                minWidth: 0,
                maxWidth: 120,
                minHeight: 30,
                idealHeight: 40
            )
            .foregroundColor(Asset.Colors.Text.activeButtonText.color)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(Asset.Colors.Buttons.activeButton.color)
            .cornerRadius(6)
    }
}

struct BlueChip_Previews: PreviewProvider {
    static var previews: some View {
        BlueChip(word: "negative")
            .applyScreenBackground()
    }
}
