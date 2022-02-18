//
//  WordChipGrid.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/28/21.
//

import SwiftUI

/// A 3x(N/3) grid of numbered or empty chips.
struct WordChipGrid: View {
    static let spacing: CGFloat = 10
    var chips: [PhraseChip.Kind]
    var coloredChipColor: Color
    var threeColumnGrid = Array(
        repeating: GridItem(
            .flexible(minimum: 100, maximum: 120),
            spacing: Self.spacing,
            alignment: .topLeading
        ),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: threeColumnGrid, alignment: .center, spacing: 10) {
            ForEach(chips, id: \.self) { item in
                PhraseChip(kind: item)
            }
        }
    }

    init(chips: [PhraseChip.Kind], coloredChipColor: Color) {
        self.chips = chips
        self.coloredChipColor = coloredChipColor
    }

    init(words: [String], startingAt index: Int, coloredChipColor: Color = .clear) {
        let chips = zip(words, index..<index + words.count).map { word, index in
            word.isEmpty ? PhraseChip.Kind.empty : .ordered(position: index, word: word)
        }
        self.init(chips: chips, coloredChipColor: coloredChipColor)
    }
}

struct WordChipGrid_Previews: PreviewProvider {
    private static var words = [
        "pyramid", "negative", "page",
        "morning", "", "zebra"
    ]

    static var previews: some View {
        WordChipGrid(words: words, startingAt: 1)
            .frame(maxHeight: .infinity)
            .fixedSize()
            .environment(\.sizeCategory, .accessibilityLarge)
            .padding()
    }
}
