//
//  RecoveryPhraseRandomizerTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension RecoveryPhraseRandomizerClient {
    static let placeholderMock = Self(random: { _ in return .placeholder })
}
