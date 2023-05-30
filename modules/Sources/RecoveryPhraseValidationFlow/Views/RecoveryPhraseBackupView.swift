//
//  RecoveryPhraseBackupView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/29/21.
//

import SwiftUI
import ComposableArchitecture
import Generated
import UIComponents
import Models

public struct RecoveryPhraseBackupView: View {
    let store: RecoveryPhraseValidationFlowStore

    var viewStore: RecoveryPhraseValidationFlowViewStore {
        ViewStore(store)
    }
    
    public init(store: RecoveryPhraseValidationFlowStore) {
        self.store = store
    }
    
    public var body: some View {
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
                    destination: { RecoveryPhraseBackupSucceededView(store: store) }
                )
                .navigationLinkEmpty(
                    isActive: viewStore.bindingForFailure,
                    destination: { RecoveryPhraseBackupFailedView(store: store) }
                )
            }
            .frame(alignment: .top)
        }
        .applyScreenBackground()
        .scrollableWhenScaledUp()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(L10n.RecoveryPhraseBackupValidation.title))
    }
}

private extension RecoveryPhraseBackupView {
    @ViewBuilder func header(for viewStore: RecoveryPhraseValidationFlowViewStore) -> some View {
        VStack {
            if viewStore.isComplete {
                completeHeader(for: viewStore.state)
            } else {
                Text(L10n.RecoveryPhraseBackupValidation.description)
                    .bodyText()
            }

            viewStore.state.missingWordGrid()
        }
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder func completeHeader(for state: RecoveryPhraseValidationFlowReducer.State) -> some View {
        if state.isValid {
            Text(L10n.RecoveryPhraseBackupValidation.successResult)
                .bodyText()
        } else {
            Text(L10n.RecoveryPhraseBackupValidation.failedResult)
                .bodyText()
        }
    }
}

private extension RecoveryPhraseValidationFlowReducer.State {
    @ViewBuilder func missingWordGrid() -> some View {
        let columns = Array(
            repeating: GridItem(.flexible(minimum: 100, maximum: 120), spacing: 20),
            count: 2
        )

        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
            ForEach(0..<missingWordChips.count, id: \.self) { chipIndex in
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

extension RecoveryPhraseValidationFlowReducer.State {
    public func wordsChips(
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

private extension WordChipGrid {
    init(
        state: RecoveryPhraseValidationFlowReducer.State,
        groupIndex: Int,
        wordGroup: RecoveryPhrase.Group,
        misingIndex: Int
    ) {
        let chips = state.wordsChips(
            for: groupIndex,
            groupSize: RecoveryPhraseValidationFlowReducer.State.wordGroupSize,
            from: wordGroup
        )

        self.init(chips: chips, coloredChipColor: state.coloredChipColor)
    }
}

private extension RecoveryPhraseValidationFlowReducer.State {
    var coloredChipColor: Color {
        if self.isComplete {
            return isValid ? Asset.Colors.Buttons.activeButton.color : Asset.Colors.BackgroundColors.red.color
        } else {
            return Asset.Colors.Buttons.activeButton.color
        }
    }
}

// MARK: - Previews

struct RecoveryPhraseBackupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecoveryPhraseValidationFlowView(store: .demoStep4)
        }

        NavigationView {
            RecoveryPhraseValidationFlowView(store: .demoStep1)
        }

        NavigationView {
            RecoveryPhraseValidationFlowView(store: .demoStep1)
        }
    }
}
