//
//  MnemonicTestKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import ComposableArchitecture
import XCTestDynamicOverlay

extension MnemonicClient: TestDependencyKey {
    public static let testValue = Self(
        randomMnemonic: XCTUnimplemented("\(Self.self).randomMnemonic", placeholder: ""),
        randomMnemonicWords: XCTUnimplemented("\(Self.self).randomMnemonicWords", placeholder: []),
        toSeed: XCTUnimplemented("\(Self.self).toSeed", placeholder: []),
        asWords: XCTUnimplemented("\(Self.self).asWords", placeholder: []),
        isValid: XCTUnimplemented("\(Self.self).isValid")
    )
}

extension MnemonicClient {
    public static let noOp = Self(
        randomMnemonic: { "" },
        randomMnemonicWords: { [] },
        toSeed: { _ in [] },
        asWords: { _ in [] },
        isValid: { _ in }
    )
}
