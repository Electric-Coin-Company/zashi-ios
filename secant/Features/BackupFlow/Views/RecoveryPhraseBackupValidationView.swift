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

    var viewStore: RecoveryPhraseValidationViewStore {
        ViewStore(store)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            header(for: viewStore)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            ZStack {
                Asset.Colors.BackgroundColors.phraseGridDarkGray.color
                    .edgesIgnoringSafeArea(.bottom)
                
                VStack(alignment: .center, spacing: 35) {
                    let state = viewStore.state
                    let groups = state.phrase.toGroups()
                    
                    ForEach(Array(zip(groups.indices, groups)), id: \.0) { index, group in
                        WordChipGrid(
                            state: state,
                            groupIndex: index,
                            wordGroup: group,
                            misingIndex: index
                        )
                            .frame(alignment: .center)
                            .background(Asset.Colors.BackgroundColors.phraseGridDarkGray.color)
                            .whenIsDroppable(
                                !state.groupCompleted(index: index),
                                dropDelegate: WordChipDropDelegate { chipKind in
                                    viewStore.send(.move(wordChip: chipKind, intoGroup: index))
                                }
                            )
                    }
                    
                    Spacer()
                }
                .padding()
                .padding(.top, 0)
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForSuccess,
                    destination: { ValidationSucceededView(store: store) }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForFailure,
                    destination: { ValidationFailedView(store: store) }
                )
            }
            .frame(alignment: .top)
        }
        .applyScreenBackground()
        .scrollableWhenScaledUp()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("recoveryPhraseBackupValidation.title"))
    }

    @ViewBuilder func header(for viewStore: RecoveryPhraseValidationViewStore) -> some View {
        VStack {
            if viewStore.isComplete {
                completeHeader(for: viewStore.state)
            } else {
                Text("recoveryPhraseBackupValidation.description")
                    .bodyText()
            }

            viewStore.state.missingWordGrid()
        }
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder func completeHeader(for state: RecoveryPhraseValidationState) -> some View {
        if state.isValid {
            Text("recoveryPhraseBackupValidation.successResult")
                .bodyText()
        } else {
            Text("recoveryPhraseBackupValidation.failedResult")
                .bodyText()
        }
    }
}

private extension RecoveryPhraseValidationState {
    @ViewBuilder func missingWordGrid() -> some View {
        let columns = Array(
            repeating: GridItem(.flexible(minimum: 100, maximum: 120), spacing: 20),
            count: 2
        )

        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
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
    func wordsChips(
        for groupIndex: Int,
        groupSize: Int,
        from wordGroup: RecoveryPhrase.Group
    ) -> [PhraseChip.Kind] {
        let validationWord = validationWords.first(where: { $0.groupIndex == groupIndex })

        return wordGroup.words.enumerated().map { index, word in
            guard index == missingIndices[groupIndex] else {
                return .ordered(position: (groupSize * groupIndex) + index + 1, word: word)
            }
            
            if let completedWord = validationWord?.word {
                return .unassigned(word: completedWord, color: self.coloredChipColor)
            }

            return .empty
        }
    }
}

extension RecoveryPhraseValidationState {
    static let placeholder = RecoveryPhraseValidationState.random(phrase: .placeholder)

    static let placeholderStep1 = RecoveryPhraseValidationState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .unassigned(word: "thank"),
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning")
        ],
        route: nil
    )

    static let placeholderStep2 = RecoveryPhraseValidationState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .unassigned(word: "garlic")
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank")
        ],
        route: nil
    )

    static let placeholderStep3 = RecoveryPhraseValidationState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .unassigned(word: "boil"),
            .empty
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank"),
            .init(groupIndex: 3, word: "garlic")
        ],
        route: nil
    )

    static let placeholderStep4 = RecoveryPhraseValidationState(
        phrase: .placeholder,
        missingIndices: [2, 0, 3, 5],
        missingWordChips: [
            .empty,
            .empty,
            .empty,
            .empty
        ],
        validationWords: [
            .init(groupIndex: 2, word: "morning"),
            .init(groupIndex: 0, word: "thank"),
            .init(groupIndex: 3, word: "garlic"),
            .init(groupIndex: 1, word: "boil")
        ],
        route: nil
    )
}

extension RecoveryPhraseValidationStore {
    private static let scheduler = DispatchQueue.main

    static let demo = Store(
        initialState: .placeholder,
        reducer: .default,
        environment: .demo
    )

    static let demoStep1 = Store(
        initialState: .placeholderStep1,
        reducer: .default,
        environment: .demo
    )

    static let demoStep2 = Store(
        initialState: .placeholderStep1,
        reducer: .default,
        environment: .demo
    )

    static let demoStep3 = Store(
        initialState: .placeholderStep3,
        reducer: .default,
        environment: .demo
    )

    static let demoStep4 = Store(
        initialState: .placeholderStep4,
        reducer: .default,
        environment: .demo
    )
}

private extension WordChipGrid {
    init(
        state: RecoveryPhraseValidationState,
        groupIndex: Int,
        wordGroup: RecoveryPhrase.Group,
        misingIndex: Int
    ) {
        let chips = state.wordsChips(
            for: groupIndex,
            groupSize: RecoveryPhraseValidationState.wordGroupSize,
            from: wordGroup
        )

        self.init(chips: chips, coloredChipColor: state.coloredChipColor)
    }
}

private extension RecoveryPhraseValidationState {
    var coloredChipColor: Color {
        if self.isComplete {
            return isValid ? Asset.Colors.Buttons.activeButton.color : Asset.Colors.BackgroundColors.red.color
        } else {
            return Asset.Colors.Buttons.activeButton.color
        }
    }
}

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryPhraseBackupValidationView(store: .demoStep4)
        }

        NavigationView {
            RecoveryPhraseBackupValidationView(store: .demoStep1)
        }

        NavigationView {
            RecoveryPhraseBackupValidationView(store: .demoStep1)
        }
        .preferredColorScheme(.dark)
    }
}
