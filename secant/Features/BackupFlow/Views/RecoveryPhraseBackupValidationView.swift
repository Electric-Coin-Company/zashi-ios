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

                    viewStore.state.step.completionWords
                        .padding(.horizontal, 30)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                VStack(spacing: 40) {
                    let step = viewStore.state.step
                    let chunks = step.phrase.toChunks()
                    ForEach(Array(zip(chunks.indices, chunks)), id: \.0) { index, chunk in
                        WordChipGrid(chips: step.wordChips(for: index, groupSize: RecoveryPhraseValidationState.wordGroupSize, from: chunk))
                            .whenIsDroppable(!step.groupCompleted(index: index), dropDelegate: step.dropDelegate(for: viewStore, group: index))
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

private extension RecoveryPhraseValidationState.Step {
    @ViewBuilder var completionWords: some View {
        switch self {
        case .initial(_, _, let missingWordsChips):
            missingWordGrid(for: missingWordsChips)
        case .incomplete(_, _, _, let missingWordsChips):
            missingWordGrid(for: missingWordsChips)
        case .complete(_, _, _, let missingWordsChips):
            missingWordGrid(for: missingWordsChips)
        case .valid(_, _, _, let missingWordsChips):
            missingWordGrid(for: missingWordsChips)
        case .invalid(_, _, _, let missingWordsChips):
            missingWordGrid(for: missingWordsChips)
        }
    }

    @ViewBuilder func missingWordGrid(for chips: [PhraseChip.Kind]) -> some View {
        let columns = Array(repeating: GridItem(.flexible(minimum: 40, maximum: 120), spacing: 20), count: 2)
        LazyVGrid(columns: columns, alignment: .center, spacing: 20 ) {
            ForEach(0..<chips.count) { chipIndex in
                PhraseChip(kind: chips[chipIndex])
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

extension RecoveryPhraseValidationState.Step {
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
        switch self {
        case .initial(_, let missingIndices, _):
            return wordsChips(for: group, groupSize: groupSize, from: chunk, with: missingIndices[group], completing: [])
        case let .incomplete(_, missingIndices, completion, _):
            return wordsChips(for: group, groupSize: groupSize, from: chunk, with: missingIndices[group], completing: completion)
        case let .complete(_, missingIndices, completion, _):
            return wordsChips(for: group, groupSize: groupSize, from: chunk, with: missingIndices[group], completing: completion)
        case .valid(_, _, let completion, _):
            return wordsChips(for: group, groupSize: groupSize, from: chunk, completions: completion)
        case .invalid(_, _, let completion, _):
            return wordsChips(for: group, groupSize: groupSize, from: chunk, completions: completion)
        }
    }
}

private extension RecoveryPhraseValidationState.Step {
    var phrase: RecoveryPhrase {
        switch self {
        case .initial(let phrase, _, _):
            return phrase
        case .incomplete(let phrase, _, _, _):
            return phrase
        case .complete(let phrase, _, _, _):
            return phrase
        case .invalid(let phrase, _, _, _):
            return phrase
        case .valid(let phrase, _, _, _):
            return phrase
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
