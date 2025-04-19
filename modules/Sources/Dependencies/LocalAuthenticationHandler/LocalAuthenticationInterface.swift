//
//  LocalAuthenticationInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 12.11.2022.
//

import ComposableArchitecture

extension DependencyValues {
    public var localAuthentication: LocalAuthenticationClient {
        get { self[LocalAuthenticationClient.self] }
        set { self[LocalAuthenticationClient.self] = newValue }
    }
}

@DependencyClient
public struct LocalAuthenticationClient {
    public enum Method: Equatable {
        case faceID
        case none
        case passcode
        case touchID
    }
    
    public let authenticate: @Sendable () async -> Bool
    public let method: @Sendable () -> Method
}
