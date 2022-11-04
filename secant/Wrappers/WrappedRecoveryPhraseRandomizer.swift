//
//  WrappedRecoveryPhraseRandomizer.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.06.2022.
//

import Foundation

struct WrappedRecoveryPhraseRandomizer {
    let random: (RecoveryPhrase) -> RecoveryPhraseValidationFlowReducer.State
}

extension WrappedRecoveryPhraseRandomizer {
    static let live = WrappedRecoveryPhraseRandomizer(
        random: { RecoveryPhraseRandomizer().random(phrase: $0) }
    )
}
