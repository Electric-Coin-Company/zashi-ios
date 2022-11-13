//
//  RecoveryPhraseRandomizerTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension RecoveryPhraseRandomizerClient: TestDependencyKey {
    static let testValue = Self(
        random: XCTUnimplemented("\(Self.self).random", placeholder: .placeholder)
    )
}
