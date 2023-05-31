//
//  RecoveryPhraseRandomizerInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import Models

extension DependencyValues {
    public var randomRecoveryPhrase: RecoveryPhraseRandomizerClient {
        get { self[RecoveryPhraseRandomizerClient.self] }
        set { self[RecoveryPhraseRandomizerClient.self] = newValue }
    }
}

public struct RecoveryPhraseRandomizerClient {
    public var random: (RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State
    
    public init(random: @escaping (RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State) {
        self.random = random
    }
}
