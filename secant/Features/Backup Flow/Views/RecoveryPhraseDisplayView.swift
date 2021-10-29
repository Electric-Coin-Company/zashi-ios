//
//  RecoveryPhraseDisplayView.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 10/26/21.
//

import SwiftUI
import ComposableArchitecture

struct RecoveryPhraseDisplayView: View {
    let store: Store<BackupPhraseState, BackupPhraseAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ScrollView {
                VStack {
                    if let chunks = viewStore.phrase?.toChunks() {
                        // swiftlint:disable:next line_length
                        Text("The following 24 words represent your funds and the security used to protect them.\n\nBack them up now! There will be a test.")
                            .bodyText()
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(chunks, id: \.startIndex) { chunk in
                                WordChipGrid(words: chunk.words, startingAt: chunk.startIndex)
                            }
                        }

                        VStack {
                            Button(action: {}) {
                                Text("Finished!")
                            }
                                .activeButtonStyle

                            Button(action: {}) {
                                Text("Copy To Buffer")
                                    .bodyText()
                            }
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
        .navigationTitle(Text("Your Secret Recovery Phrase"))
        .navigationBarTitleDisplayMode(.inline)
        .applyScreenBackground()
    }
}

struct RecoveryPhraseDisplayView_Previews: PreviewProvider {
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
        initialState: BackupPhraseState(phrase: recoveryPhrase),
        reducer: backupFlowReducer,
        environment: BackupPhraseEnvironment(
            mainQueue: scheduler.eraseToAnyScheduler(),
            newPhrase: { Effect(value: recoveryPhrase) }
        )
    )

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
