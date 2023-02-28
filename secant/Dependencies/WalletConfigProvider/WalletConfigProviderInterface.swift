//
//  WalletConfigProviderInterface.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation
import Combine

extension DependencyValues {
    var walletConfigProvider: WalletConfigProviderClient {
        get { self[WalletConfigProviderClient.self] }
        set { self[WalletConfigProviderClient.self] = newValue }
    }
}

struct WalletConfigProviderClient {
    let load: () -> AnyPublisher<WalletConfig, Never>
    let update: (FeatureFlag, Bool) -> AnyPublisher<Void, Never>
}
