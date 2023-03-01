//
//  RecoveryPhraseRandomizerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    var randomRecoveryPhrase: RecoveryPhraseRandomizerClient {
        get { self[RecoveryPhraseRandomizerClient.self] }
        set { self[RecoveryPhraseRandomizerClient.self] = newValue }
    }
}

struct RecoveryPhraseRandomizerClient {
    var random: (RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State
}
