//
//  RecoveryPhraseDisplayView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseDisplayView: View {
    let store: RecoveryPhraseDisplayStore

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                VStack {
                    if let chunks = viewStore.phrase?.toChunks() {
                        VStack(spacing: 20) {
                            Text("Your Secret Recovery Phrase")
                                .titleText()
                            // swiftlint:disable:next line_length
                            Text("The following 24 words represent your funds and the security used to protect them.\n\nBack them up now! There will be a test.")
                                .bodyText()
                                .frame(alignment: .center)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(chunks, id: \.startIndex) { chunk in
                                WordChipGrid(words: chunk.words, startingAt: chunk.startIndex)
                            }
                        }

                        VStack {
                            Button(
                                action: { viewStore.send(.finishedPressed) },
                                label: { Text("Finished!") }
                            )
                            .activeButtonStyle
                            .frame(height: 60)

                            Button(
                                action: {
                                    viewStore.send(.copyToBufferPressed)
                                },
                                label: {
                                    Text("Copy To Buffer")
                                        .bodyText()
                                }
                            )
                            .frame(height: 60)
                        }
                        .padding()
                    } else {
                        Text("Oops no words")
                    }
                }
                .padding()
            }
            .padding(.horizontal)
        }

        // TODO: NavigationBar Style
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}
// TODO: This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight
extension RecoveryPhraseDisplayStore {
    static var demo: RecoveryPhraseDisplayStore {
        RecoveryPhraseDisplayStore(
            initialState: RecoveryPhraseDisplayState(phrase: RecoveryPhrase.demo),
            reducer: RecoveryPhraseDisplayReducer.default,
            environment: BackupPhraseEnvironment.demo
        )
    }
}

extension BackupPhraseEnvironment {
    static let demo = BackupPhraseEnvironment(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        newPhrase: { Effect(value: RecoveryPhrase.demo) }
    )
}
// TODO: This should have a #DEBUG tag, but if so, it's not possible to compile this on release mode and submit it to testflight
extension RecoveryPhrase {
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

    static let demo = RecoveryPhrase(words: testPhrase)
}

struct RecoveryPhraseDisplayView_Previews: PreviewProvider {
    static let scheduler = DispatchQueue.main

    static let store = RecoveryPhraseDisplayStore.demo

    static var previews: some View {
        NavigationView {
            RecoveryPhraseDisplayView(store: store)
        }

        NavigationView {
            RecoveryPhraseDisplayView(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
