//
//  NewRecoveryPhrase.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.11.2022.
//

import ComposableArchitecture

// TODO: Ensure that sensitive information can't be logged intentionally or by accident #444.
// https://github.com/zcash/secant-ios-wallet/issues/444
private enum NewPhrase: DependencyKey {
    static let liveValue = { RecoveryPhrase.init(words: RecoveryPhrase.placeholder.words) }
    static let testValue = { RecoveryPhrase.init(words: RecoveryPhrase.placeholder.words) }
}

extension DependencyValues {
    var newPhrase: () -> RecoveryPhrase {
        get { self[NewPhrase.self] }
        set { self[NewPhrase.self] = newValue }
    }
}
