//
//  EnumeratedChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/19/21.
//

import SwiftUI

struct EnumeratedChip: View {
    @Clamped(1...24)
    var index: Int = 1
    var text: String

    var body: some View {
        GeometryReader { geometry in
        (Text("\(index)")
            .baselineOffset(geometry.size.height / 4)
            .foregroundColor(Asset.Colors.Text.highlightedSuperscriptText.color)
            .font(.custom(FontFamily.Roboto.bold.name, size: 12)) +

        Text(" \(text)")
            .foregroundColor(Asset.Colors.Text.button.color)
            .font(.custom(FontFamily.Rubik.regular.name, size: 14))
        )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 14)
                .padding([.trailing, .vertical], 4)
                .fixedSize(horizontal: false, vertical: true)
            .shadow(
                color: Asset.Colors.Shadow.numberedTextShadow.color,
                radius: 1,
                x: 0,
                y: 1
            )
            .background(Asset.Colors.BackgroundColors.numberedChip.color)
            .cornerRadius(6)
            .shadow(color: Asset.Colors.Shadow.numberedTextShadow.color, radius: 3, x: 0, y: 1)
        }
    }
}

struct EnumeratedChip_Previews: PreviewProvider {
    private static var words = [
        "pyramid", "negative", "page",
        "crown", "", "zebra"
    ]

    @ViewBuilder static var grid: some View {
        WordChipGrid(words: words, startingAt: 1)
    }

    static var previews: some View {
        grid
            .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
            .previewLayout(.fixed(width: 428, height: 200))

        grid
            .applyScreenBackground()
            .previewLayout(.fixed(width: 428, height: 200))

        grid
            .applyScreenBackground()
            .previewLayout(.fixed(width: 428, height: 200))

        grid
            .applyScreenBackground()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 428, height: 200))

        grid
            .applyScreenBackground()
            .previewLayout(.fixed(width: 390, height: 200))

        grid
            .applyScreenBackground()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 390, height: 200))

        grid
            .applyScreenBackground()
            .previewLayout(.fixed(width: 375, height: 200))

        grid
            .applyScreenBackground()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 375, height: 200))

        grid
            .applyScreenBackground()
            .previewLayout(.fixed(width: 320, height: 200))

        grid
            .applyScreenBackground()
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 320, height: 200))
    }
}
