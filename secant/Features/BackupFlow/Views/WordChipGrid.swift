//
//  WordChipGrid.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/28/21.
//

import SwiftUI

/**
A 3x2 grid of numbered or empty chips.
*/
struct WordChipGrid: View {
    static let spacing: CGFloat = 10
    var chips: [PhraseChip.Kind]
    var coloredChipColor: Color
    var threeColumnGrid = Array(
        repeating: GridItem(
            .flexible(minimum: 60, maximum: 120),
            spacing: Self.spacing,
            alignment: .topLeading
        ),
        count: 3
    )

    var body: some View {
        LazyVGrid(
            columns: threeColumnGrid,
            alignment: .leading,
            spacing: Self.spacing
        ) {
            ForEach(chips, id: \.self) { wordChip in
                chipView(for: wordChip)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 30
                    )
            }
        }
    }
    init(chips: [PhraseChip.Kind], coloredChipColor: Color) {
        self.chips = chips
        self.coloredChipColor = coloredChipColor
    }

    init(words: [String], startingAt index: Int, coloredChipColor: Color = .clear) {
        let chips = zip(words, index..<index + words.count).map({ word, index in
            word.isEmpty ? PhraseChip.Kind.empty : .ordered(position: index, word: word)
        })
        self.init(chips: chips, coloredChipColor: coloredChipColor)
    }

    @ViewBuilder func chipView(for chipKind: PhraseChip.Kind) -> some View {
        switch chipKind {
        case .empty:
            EmptyChip()

        case let .ordered(position, word):
            EnumeratedChip(index: position, text: word)

        case .unassigned(let word):
            ColoredChip(word: word, color: coloredChipColor)
        }
    }
}

struct WordChipGrid_Previews: PreviewProvider {
    private static var words = [
        "pyramid", "negative", "page",
        "crown", "", "zebra"
    ]

    static var previews: some View {
        VStack {
            WordChipGrid(words: words, startingAt: 1)
        }
        .padding()
    }
}
