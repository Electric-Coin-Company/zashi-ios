//
//  WalletStorageKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.11.2022.
//

import ComposableArchitecture

private enum WalletStorageKey: DependencyKey {
    static let liveValue = WrappedWalletStorage.live()
    static let testValue = WrappedWalletStorage.throwing
}

extension DependencyValues {
    var walletStorage: WrappedWalletStorage {
        get { self[WalletStorageKey.self] }
        set { self[WalletStorageKey.self] = newValue }
    }
}
