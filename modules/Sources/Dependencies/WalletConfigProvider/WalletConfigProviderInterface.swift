//
//  WalletConfigProviderInterface.swift
//  secant
//
//  Created by Michal Fousek on 23.02.2023.
//

import ComposableArchitecture
import Foundation
import Combine
import Models

extension DependencyValues {
    public var walletConfigProvider: WalletConfigProviderClient {
        get { self[WalletConfigProviderClient.self] }
        set { self[WalletConfigProviderClient.self] = newValue }
    }
}

public struct WalletConfigProviderClient {
    public let load: () -> AnyPublisher<WalletConfig, Never>
    public let update: (FeatureFlag, Bool) -> AnyPublisher<Void, Never>
}
