//
//  WalletConfigProviderInterface.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var walletConfigProvider: WalletConfigProviderClient {
        get { self[WalletConfigProviderClient.self] }
        set { self[WalletConfigProviderClient.self] = newValue }
    }
}

struct WalletConfigProviderClient {
    let load: () async -> WalletConfig
    let update: (FeatureFlag, Bool) async -> Void
}
