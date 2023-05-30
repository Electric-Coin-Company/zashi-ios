//
//  LocalAuthenticationInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture
import LocalAuthentication

extension DependencyValues {
    public var localAuthentication: LocalAuthenticationClient {
        get { self[LocalAuthenticationClient.self] }
        set { self[LocalAuthenticationClient.self] = newValue }
    }
}

public struct LocalAuthenticationClient {
    public let authenticate: @Sendable (String) async -> Bool
}
