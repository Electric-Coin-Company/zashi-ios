//
//  LocalAuthenticationMocks.swift
//  Zashi
//
//  Created by Lukáš Korba on 12.11.2022.
//

extension LocalAuthenticationClient {
    public static let mockAuthenticationSucceeded = Self(
        authenticate: { true },
        method: { .none }
    )
    
    public static let mockAuthenticationFailed = Self(
        authenticate: { false },
        method: { .none }
    )
}
