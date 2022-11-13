//
//  RecoveryPhraseRandomizerLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import ComposableArchitecture

extension RecoveryPhraseRandomizerClient: DependencyKey {
    static let liveValue = Self(
        random: { RecoveryPhraseRandomizer().random(phrase: $0) }
    )
}
