//
//  RecoveryPhraseBackupView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseBackupValidationView: View {
    let store: Store<RecoveryPhraseValidationState, RecoveryPhraseValidationAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                VStack {
                    Text("Drag the words below to match your backed-up copy.")
                        .bodyText()

                    viewStore.state.step.completionWords
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)

                VStack(spacing: 40) {
                    viewStore.state.step.wordGroups
                }
                .padding()
                .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("Verify Your Backup"))
    }
}

private extension RecoveryPhraseValidationStep {
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
            ForEach(chips, id: \.self) { chip in
                PhraseChip(kind: chip)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 30
                    )
            }
        }
        .padding(0)
    }

    @ViewBuilder var wordGroups: some View {
        switch self {
        case let .initial(phrase, missingIndices, missingWordsChips):
            initialWordGroups(phrase: phrase, missingIndices: missingIndices, missingWordChips: missingWordsChips)

        case let .incomplete(phrase, missingIndices, completion, missingWordsChips):
            Text("hola")
        case let .complete(phrase, missingIndices, completion, missingWordsChips):
            Text("hola")
        case let .valid(phrase, missingIndices, completion, missingWordsChips):
            Text("hola")
        case let .invalid(phrase, missingIndices, completion, missingWordsChips):
            Text("hola")
        }
    }

    @ViewBuilder func initialWordGroups(phrase: RecoveryPhrase, missingIndices: [Int], missingWordChips: [PhraseChip.Kind]) -> some View {
        let chunks = phrase.toChunks()
        ForEach(Array(zip(chunks.indices, chunks)), id: \.0) { index, chunk in
            WordChipGrid(words: chunk.words(with: missingIndices[index]), startingAt: chunk.startIndex)
        }
    }
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static let scheduler = DispatchQueue.main

    static let testPhrase = [
        // 1
        "bring", "salute", "thank",
        "require", "spirit", "toe",
        // 7
        "boil", "hill", "casino",
        "trophy", "drink", "frown",
        // 13
        "bird", "grit", "close",
        "morning", "bind", "cancel",
        // 19
        "daughter", "salon", "quit",
        "pizza", "just", "garlic"
    ]

    static let recoveryPhrase = RecoveryPhrase(words: testPhrase)

    static let store = Store(
        initialState: RecoveryPhraseValidationState(phrase: recoveryPhrase),
        reducer: validatePhraseFlowReducer,
        environment: RecoveryPhraseEnvironment(
            mainQueue: scheduler.eraseToAnyScheduler(),
            newPhrase: { Effect(value: recoveryPhrase) }
        )
    )

    static var previews: some View {
        RecoveryPhraseBackupValidationView(store: store)
    }
}
