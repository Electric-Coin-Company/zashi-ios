//
//  Pasteboard.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 01.11.2022.
//

import ComposableArchitecture

// TODO: Ensure that sensitive information can't be logged intentionally or by accident #444.
// https://github.com/zcash/secant-ios-wallet/issues/444
private enum Pasteboard: DependencyKey {
    static let liveValue = WrappedPasteboard.live
    static let testValue = WrappedPasteboard.test
}

extension DependencyValues {
    var pasteboard: WrappedPasteboard {
        get { self[Pasteboard.self] }
        set { self[Pasteboard.self] = newValue }
    }
}