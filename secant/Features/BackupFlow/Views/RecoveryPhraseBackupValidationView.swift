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
                header(for: viewStore)
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                VStack(spacing: 20) {
                    let state = viewStore.state
                    let chunks = state.phrase.toChunks()
                    ForEach(Array(zip(chunks.indices, chunks)), id: \.0) { index, chunk in
                        WordChipGrid(
                            state: state,
                            group: index,
                            chunk: chunk,
                            misingIndex: index
                        )
                        .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
                        .whenIsDroppable(!state.groupCompleted(index: index), dropDelegate: state.dropDelegate(for: viewStore, group: index))
                    }
                }
                .padding()
                .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
            }
            .applyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewTitle(for: viewStore))
        }
    }
    @ViewBuilder func header(for viewStore: RecoveryPhraseValidationViewStore) -> some View {
        switch viewStore.step {
        case .initial, .incomplete:
            VStack {
                Text("Drag the words below to match your backed-up copy.")
                    .bodyText()

                viewStore.state.missingWordGrid()
                    .padding(.horizontal, 30)
            }
        case .complete:
            VStack {
                completeHeader(for: viewStore.state)
            }
        }
    }
    
    @ViewBuilder func completeHeader(for state: RecoveryPhraseValidationState) -> some View {
        if state.isValid {
            Text("Valid - TODO")
                .bodyText()
        } else {
            Text("Your placed words did not match your secret recovery phrase")
                .bodyText()
        }
    }
    
    func viewTitle(for store: RecoveryPhraseValidationViewStore) -> Text {
        switch store.state.step {
        case .initial, .incomplete:
            return Text("Verify Your Backup")
        case .complete:
            return store.state.isValid ? Text("Success!") : Text("Ouch, sorry, no.")
        }
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

extension RecoveryPhraseValidationState {
    func wordsChips(for group: Int, groupSize: Int, from chunk: RecoveryPhrase.Chunk) -> [PhraseChip.Kind] {
        let wordCompletion = completion.first(where: { $0.groupIndex == group })

        var chips: [PhraseChip.Kind] = []
        for (i, word) in chunk.words.enumerated() {
            if i == missingIndices[group] {
                if let completedWord = wordCompletion?.word {
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

private extension WordChipGrid {
    init(
        state: RecoveryPhraseValidationState,
        group: Int,
        chunk: RecoveryPhrase.Chunk,
        misingIndex: Int
    ) {
        let chips = state.wordsChips(for: group, groupSize: RecoveryPhraseValidationState.wordGroupSize, from: chunk)
        self.init(chips: chips)
    }
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demo)
    }
}
