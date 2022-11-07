//
//  DerivationToolKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 05.11.2022.
//

import ComposableArchitecture

private enum DerivationToolKey: DependencyKey {
    static let liveValue = WrappedDerivationTool.live()
    static let testValue = WrappedDerivationTool.live()
}

extension DependencyValues {
    var derivationTool: WrappedDerivationTool {
        get { self[DerivationToolKey.self] }
        set { self[DerivationToolKey.self] = newValue }
    }
}
