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
        NumberedText(number: index, text: text)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 30,
                idealHeight: 40,
                maxHeight: .infinity,
                alignment: .leading
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(
                Asset.Colors.Buttons.primaryButtonPressed.color
            )
            .cornerRadius(6)
    }
}

struct NumberedText: View {
    var number: Int = 1
    var text: String

    @ViewBuilder var numberedText: some View {
        Text(number.superscriptRepresentation)
            .foregroundColor(
                Asset.Colors.Text.highlightedSuperscriptText.color
            )
            .font(
                .custom(
                    FontFamily.Roboto.bold.name,
                    size: 20
                )
            ) +
        Text(" \(text)")
            .foregroundColor(
                Asset.Colors.Text.button.color
            )
            .font(
                .custom(
                    FontFamily.Rubik.medium.name,
                    size: 16
                )
            )
    }

    var body: some View {
        numberedText
            .shadow(
                color: Asset.Colors.Shadow.buttonTextShadow.color,
                radius: 1,
                x: 0,
                y: 1
            )
            .layoutPriority(1)
            .fixedSize(horizontal: false, vertical: false)
    }
}

struct EnumeratedChip_Previews: PreviewProvider {
    private static var threeColumnGrid = Array(
        repeating: GridItem(
            .flexible(minimum: 60, maximum: 120),
            spacing: 15,
            alignment: .topLeading
        ),
        count: 3
    )

    static var words = [
        "pyramid", "negative", "page",
        "crown", "", "zebra"
    ]

    @ViewBuilder static var grid: some View {
        LazyVGrid(
            columns: threeColumnGrid,
            alignment: .leading,
            spacing: 15
        ) {
            ForEach(Array(zip(words.indices, words)), id: \.1) { i, word in
                if word.isEmpty {
                    EmptyChip()
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 30,
                            idealHeight: 40
                        )
                } else {
                    EnumeratedChip(index: (i + 1), text: word)
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 30,
                            idealHeight: 40
                        )
                }
            }
        }
        .padding()
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
