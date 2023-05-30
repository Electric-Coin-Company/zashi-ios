//
//  WordChipGrid.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/28/21.
//

import SwiftUI
import Utils

/// A 3x(N/3) grid of numbered or empty chips.
public struct WordChipGrid: View {
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

    public var body: some View {
        LazyVGrid(columns: threeColumnGrid, alignment: .center, spacing: 10) {
            ForEach(chips, id: \.self) { item in
                PhraseChip(kind: item)
            }
        }
    }

    public init(chips: [PhraseChip.Kind], coloredChipColor: Color) {
        self.chips = chips
        self.coloredChipColor = coloredChipColor
    }

    public init(words: [RedactableString], startingAt index: Int, coloredChipColor: Color = .clear) {
        let chips = zip(words, index..<index + words.count).map { word, index in
            word.data.isEmpty ? PhraseChip.Kind.empty : .ordered(position: index, word: word)
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
        WordChipGrid(words: words.map { $0.redacted }, startingAt: 1)
            .frame(maxHeight: .infinity)
            .fixedSize()
            .padding()
    }
}
