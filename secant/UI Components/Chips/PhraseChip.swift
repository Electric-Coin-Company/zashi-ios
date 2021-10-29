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
        case unassigned(word: String)
        case ordered(position: Int, word: String)
    }

    var kind: Kind

    var body: some View {
        chipFor(for: kind)
            .frame(
                minWidth: 0,
                maxWidth: 120,
                minHeight: 30,
                idealHeight: 40
            )
            .animation(.easeIn)
    }

    @ViewBuilder func chipFor(for kind: Kind) -> some View {
        switch kind {
        case .empty:
            EmptyChip()

        case let .ordered(position, word):
            EnumeratedChip(index: position, text: word)

        case .unassigned(let word):
            BlueChip(word: word)
        }
    }
}

struct PhraseChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PhraseChip(kind: .unassigned(word: "negative"))
                .frame(height: 40)

            PhraseChip(kind: .empty)
                .frame(height: 40)

            PhraseChip(kind: .ordered(position: 23, word: "mutual"))
                .frame(height: 40)
        }
        .applyScreenBackground()
    }
}
