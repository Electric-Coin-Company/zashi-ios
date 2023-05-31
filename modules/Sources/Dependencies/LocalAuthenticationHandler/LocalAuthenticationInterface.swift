//
//  LocalAuthenticationInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import LocalAuthenticationHandler

extension DependencyValues {
    public var localAuthentication: LocalAuthenticationClient {
        get { self[LocalAuthenticationClient.self] }
        set { self[LocalAuthenticationClient.self] = newValue }
    }
}

public struct LocalAuthenticationClient {
    public let authenticate: @Sendable () async -> Bool
}
