//
//  PhraseChip.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/25/21.
//

import SwiftUI

struct PhraseChip: View {
    enum Kind: Hashable {
        case empty
        case unassigned(word: String, color: Color = Asset.Colors.Buttons.activeButton.color)
        case ordered(position: Int, word: String)
    }

    var kind: Kind

    var body: some View {
        switch kind {
        case .empty:
            EmptyChip()
        case let .ordered(position, word):
            EnumeratedChip(index: position, text: word)
        case let .unassigned(word, color):
            ColoredChip(word: word, color: color)
        }
    }
}

struct PhraseChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PhraseChip(kind: .unassigned(word: "negative"))
                .frame(width: 120, height: 40)

            PhraseChip(kind: .empty)
                .frame(width: 120, height: 40)

            PhraseChip(kind: .ordered(position: 23, word: "mutual"))
                .frame(width: 120, height: 40)
        }
        .applyScreenBackground()
    }
}
