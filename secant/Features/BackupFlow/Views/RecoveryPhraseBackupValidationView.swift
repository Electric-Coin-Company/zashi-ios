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
                ZStack {
                    Asset.Colors.BackgroundColors.phraseGridDarkGray.color
                        .edgesIgnoringSafeArea(.bottom)
                    VStack(spacing: 35) {
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
                        Spacer()
                    }
                    .padding()
                    .padding(.top, 0)
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForRoute(.success),
                        destination: { view(for: .success) }
                    )
                    .navigationLinkEmpty(
                        isActive: viewStore.bindingForRoute(.failure),
                        destination: { view(for: .failure) }
                    )
                }
                .frame(alignment: .top)
            }
            .applyScreenBackground()
            .scrollableWhenScaledUp()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Verify Your Backup"))
        }
    }

    @ViewBuilder func header(for viewStore: RecoveryPhraseValidationViewStore) -> some View {
        VStack {
            switch viewStore.step {
            case .initial, .incomplete:
                Text("Drag the words below to match your backed-up copy.")
                    .bodyText()
            case .complete:
                completeHeader(for: viewStore.state)
            }
            viewStore.state.missingWordGrid()
        }
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder func completeHeader(for state: RecoveryPhraseValidationState) -> some View {
        if state.isValid {
            Text("Congratulations! You validated your secret recovery phrase.")
                .bodyText()
        } else {
            Text("Your placed words did not match your secret recovery phrase")
                .bodyText()
        }
    }

    @ViewBuilder func view(for route: RecoveryPhraseValidationState.Route) -> some View {
        switch route {
        case .success:
            ValidationSuccededView(store: store)
        case .failure:
            ValidationFailedView(store: store)
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
        let wordCompletion = validationWords.first(where: { $0.groupIndex == group })

        var chips: [PhraseChip.Kind] = []
        for (index, word) in chunk.words.enumerated() {
            if index == missingIndices[group] {
                if let completedWord = wordCompletion?.word {
                    chips.append(.unassigned(word: completedWord))
                } else {
                    chips.append(.empty)
                }
            } else {
                chips.append(.ordered(position: (groupSize * group) + index + 1, word: word))
            }
        }
        return chips
    }
}

extension RecoveryPhraseValidationState {
    static let placeholder = RecoveryPhraseValidationState.random(phrase: RecoveryPhrase.placeholder)

    static let placeholderStep1 = RecoveryPhraseValidationState(
        phrase: RecoveryPhrase.placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .unassigned(word: "thank"),
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            ValidationWord(groupIndex: 2, word: "morning")
        ],
        route: nil
    )

    static let placeholderStep2 = RecoveryPhraseValidationState(
        phrase: RecoveryPhrase.placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            ValidationWord(groupIndex: 2, word: "morning"),
            ValidationWord(groupIndex: 0, word: "thank")
        ],
        route: nil
    )

    static let placeholderStep3 = RecoveryPhraseValidationState(
        phrase: RecoveryPhrase.placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .empty
        ],
        validationWords: [
            ValidationWord(groupIndex: 2, word: "morning"),
            ValidationWord(groupIndex: 0, word: "thank"),
            ValidationWord(groupIndex: 3, word: "garlic")
        ],
        route: nil
    )

    static let placeholderStep4 = RecoveryPhraseValidationState(
        phrase: RecoveryPhrase.placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .empty,
            .empty
        ],
        validationWords: [
            ValidationWord(groupIndex: 2, word: "morning"),
            ValidationWord(groupIndex: 0, word: "thank"),
            ValidationWord(groupIndex: 3, word: "garlic"),
            ValidationWord(groupIndex: 1, word: "boil")
        ],
        route: nil
    )
}

extension RecoveryPhraseValidationStore {
    private static let scheduler = DispatchQueue.main

    static let demo = Store(
        initialState: RecoveryPhraseValidationState.placeholder,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
    )

    static let demoStep1 = Store(
        initialState: RecoveryPhraseValidationState.placeholderStep1,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
    )

    static let demoStep2 = Store(
        initialState: RecoveryPhraseValidationState.placeholderStep1,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
    )

    static let demoStep3 = Store(
        initialState: RecoveryPhraseValidationState.placeholderStep3,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
    )

    static let demoStep4 = Store(
        initialState: RecoveryPhraseValidationState.placeholderStep4,
        reducer: .default,
        environment: BackupPhraseEnvironment.demo
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
        self.init(chips: chips, coloredChipColor: state.coloredChipColor)
    }
}

private extension RecoveryPhraseValidationState {
    var coloredChipColor: Color {
        switch self.step {
        case .initial, .incomplete:
            return Asset.Colors.Buttons.activeButton.color
        case .complete:
            return isValid ? Asset.Colors.Buttons.activeButton.color : Asset.Colors.BackgroundColors.red.color
        }
    }
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demoStep4)
        }

        NavigationView {
            RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demoStep1)
        }

        NavigationView {
            RecoveryPhraseBackupValidationView(store: RecoveryPhraseValidationStore.demoStep1)
        }
        .preferredColorScheme(.dark)
    }
}
