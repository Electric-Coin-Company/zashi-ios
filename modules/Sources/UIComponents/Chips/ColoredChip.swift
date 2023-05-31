//
//  BlueChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/25/21.
//

import SwiftUI
import Utils
import Generated

public struct ColoredChip: View {
    let word: RedactableString
    let color: Color = Asset.Colors.Buttons.activeButton.color
    
    public init(word: RedactableString, color: Color = Asset.Colors.Buttons.activeButton.color) {
        self.word = word
    }
    
    public var body: some View {
        Text(word.data)
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
        ColoredChip(
            word: "negative".redacted
        )
        .frame(width: 115)
        .applyScreenBackground()
    }
}
