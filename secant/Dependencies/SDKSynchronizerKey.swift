//
//  SDKSynchronizerKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.11.2022.
//

import ComposableArchitecture

private enum SDKSynchronizerKey: DependencyKey {
    static let liveValue: WrappedSDKSynchronizer = LiveWrappedSDKSynchronizer()
    static let testValue: WrappedSDKSynchronizer = MockWrappedSDKSynchronizer()
}

extension DependencyValues {
    var sdkSynchronizer: WrappedSDKSynchronizer {
        get { self[SDKSynchronizerKey.self] }
        set { self[SDKSynchronizerKey.self] = newValue }
    }
}
