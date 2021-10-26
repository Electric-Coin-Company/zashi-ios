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
            if let phrase = viewStore.phrase?.words {
                Text(phrase.joined(separator: " "))
            } else {
                Text("Oops no words")
            }
        }
        .applyScreenBackground()
    }
}

struct RecoveryPhraseDisplayView_Previews: PreviewProvider {
    static let scheduler = DispatchQueue.main
    // swiftlint:disable:next line_length
    static let testPhrase: [String] = ["bring", "salute", "thank", "require", "spirit", "toe", "boil", "hill", "casino", "trophy", "drink", "frown", "bird", "grit", "close", "morning", "bind", "cancel", "daughter", "salon", "quit", "pizza", "just", "garlic"]

    static let recoveryPhrase = RecoveryPhrase(words: testPhrase)
    static let store = Store(
        initialState: BackupPhraseState(phrase: recoveryPhrase),
        reducer: backupFlowReducer,
        environment: BackupPhraseEnvironment(
            mainQueue: scheduler.eraseToAnyScheduler(),
            newPhrase: {
                Effect(value: recoveryPhrase)
            }
        )
    )
    static var previews: some View {
        RecoveryPhraseDisplayView(store: store)
    }
}
