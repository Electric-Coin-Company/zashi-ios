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
    var chips: [PhraseChip.Kind]

    var threeColumnGrid = Array(
        repeating: GridItem(
            .flexible(minimum: 60, maximum: 120),
            spacing: 15,
            alignment: .topLeading
        ),
        count: 3
    )

    var body: some View {
        LazyVGrid(
            columns: threeColumnGrid,
            alignment: .leading,
            spacing: 15
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

    init(words: [String], startingAt index: Int) {
        self.chips = zip(words, index..<index + words.count).map({ word, index in
            word.isEmpty ? .empty : .ordered(position: index, word: word)
        })
    }

    @ViewBuilder func chipView(for chipKind: PhraseChip.Kind) -> some View {
        switch chipKind {
        case .empty:
            EmptyChip()

        case let .ordered(position, word):
            EnumeratedChip(index: position, text: word)

        case .unassigned(let word):
            BlueChip(word: word)
        }
    }
}

struct WordChipGrid_Previews: PreviewProvider {
    private static var words = [
        "pyramid", "negative", "page",
        "crown", "", "zebra"
    ]

    static var previews: some View {
        WordChipGrid(words: words, startingAt: 1)
    }
}
