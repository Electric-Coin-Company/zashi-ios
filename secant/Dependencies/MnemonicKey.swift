//
//  MnemonicKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.11.2022.
//

import ComposableArchitecture

private enum MnemonicKey: DependencyKey {
    static let liveValue = WrappedMnemonic.live
    static let testValue = WrappedMnemonic.mock
}

extension DependencyValues {
    var mnemonic: WrappedMnemonic {
        get { self[MnemonicKey.self] }
        set { self[MnemonicKey.self] = newValue }
    }
}
