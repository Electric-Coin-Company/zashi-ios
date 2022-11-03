//
//  NewRecoveryPhrase.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.11.2022.
//

import ComposableArchitecture

// TODO: Ensure that sensitive information can't be logged intentionally or by accident #444.
// https://github.com/zcash/secant-ios-wallet/issues/444
private enum NewRecoveryPhraseKey: DependencyKey {
    static let liveValue = { RecoveryPhrase.init(words: RecoveryPhrase.placeholder.words) }
    static let testValue = { RecoveryPhrase.init(words: RecoveryPhrase.placeholder.words) }
}

extension DependencyValues {
    var newRecoveryPhrase: () -> RecoveryPhrase {
        get { self[NewRecoveryPhraseKey.self] }
        set { self[NewRecoveryPhraseKey.self] = newValue }
    }
}
