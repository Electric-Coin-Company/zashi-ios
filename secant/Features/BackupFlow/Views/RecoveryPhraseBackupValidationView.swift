//
//  RecoveryPhraseBackupView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseBackupValidationView: View {
    let store: RecoveryPhraseValidationStore

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                VStack {
                    Text("Drag the words below to match your backed-up copy.")
                        .bodyText()

                    viewStore.state.missingWordGrid()
                        .padding(.horizontal, 30)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                VStack(spacing: 20) {
                    let state = viewStore.state
                    let chunks = state.phrase.toChunks()
                    ForEach(Array(zip(chunks.indices, chunks)), id: \.0) { index, chunk in
                        WordChipGrid(chips: state.wordChips(for: index, groupSize: RecoveryPhraseValidationState.wordGroupSize, from: chunk))
                            .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
                            .whenIsDroppable(!state.groupCompleted(index: index), dropDelegate: state.dropDelegate(for: viewStore, group: index))
                    }
                }
                .padding()
                .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)

            }
            .applyScreenBackground()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Verify Your Backup"))
    }
}

private extension RecoveryPhraseValidationState {
    @ViewBuilder func missingWordGrid() -> some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 40, maximum: 120), spacing: 20), count: 2)
        LazyVGrid(columns: columns, alignment: .center, spacing: 20 ) {
            ForEach(0..<missingWordChips.count) { chipIndex in
                PhraseChip(kind: missingWordChips[chipIndex])
                    .makeDraggable()
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 30
                    )
            }
        }
        .padding(0)
    }
}

extension RecoveryPhraseValidationState{
    func wordsChips(for group: Int, groupSize: Int, from chunk: RecoveryPhrase.Chunk, with missingIndex: Int, completing completions: [RecoveryPhraseStepCompletion]) -> [PhraseChip.Kind] {
        let completion = completions.first(where: { $0.groupIndex == group })

        var chips: [PhraseChip.Kind] = []
        for (i, word) in chunk.words.enumerated() {
            if i == missingIndex {
                if let completedWord = completion?.word {
                    chips.append(.unassigned(word: completedWord))
                } else {
                    chips.append(.empty)
                }
            } else {
                chips.append(.ordered(position: (groupSize * group) + i + 1, word: word))
            }
        }
        return chips
    }

    func wordsChips(for group: Int, groupSize: Int, from chunk: RecoveryPhrase.Chunk, completions: [RecoveryPhraseStepCompletion]) -> [PhraseChip.Kind] {
        let completion = completions.first(where: { $0.groupIndex == group })
        precondition(completion != nil, "there is no completion for group \(group). This is probably a programming error")
        var chips: [PhraseChip.Kind] = []
        for (i, word) in chunk.words.enumerated() {
            if let completedWord = completion?.word {
                chips.append(.unassigned(word: completedWord))
            } else {
                chips.append(.ordered(position: (groupSize * group) + i + 1, word: word))
            }
        }
        return chips
    }

    func wordChips(for group: Int, groupSize: Int, from chunk: RecoveryPhrase.Chunk) -> [PhraseChip.Kind] {
        switch self.step {
        case .initial, .incomplete, .complete:
            return wordsChips(for: group, groupSize: groupSize, from: chunk, with: missingIndices[group], completing: completion)
        case .valid, .invalid:
            return wordsChips(for: group, groupSize: groupSize, from: chunk, completions: completion)
        }
    }
}

extension RecoveryPhraseValidationState {
    static let placeholder = RecoveryPhraseValidationState.random(phrase: RecoveryPhrase.placeholder)
}

extension RecoveryPhraseValidationStore {
    private static let scheduler = DispatchQueue.main

    static let demo = Store(
        initialState: RecoveryPhraseValidationState.placeholder,
        reducer: .default,
        environment: ()
    )
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demo)
    }
}
