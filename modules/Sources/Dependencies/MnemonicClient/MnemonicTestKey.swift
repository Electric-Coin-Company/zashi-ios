//
//  MnemonicTestKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension MnemonicClient: TestDependencyKey {
    public static let testValue = Self(
        randomMnemonic: unimplemented("\(Self.self).randomMnemonic", placeholder: ""),
        randomMnemonicWords: unimplemented("\(Self.self).randomMnemonicWords", placeholder: []),
        toSeed: unimplemented("\(Self.self).toSeed", placeholder: []),
        asWords: unimplemented("\(Self.self).asWords", placeholder: []),
        isValid: unimplemented("\(Self.self).isValid", placeholder: {}()),
        suggestWords: unimplemented("\(Self.self).suggestWords", placeholder: [])
    )
}

extension MnemonicClient {
    public static let noOp = Self(
        randomMnemonic: { "" },
        randomMnemonicWords: { [] },
        toSeed: { _ in [] },
        asWords: { _ in [] },
        isValid: { _ in },
        suggestWords: { _ in [] }
    )
}
