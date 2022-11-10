//
//  LocalAuthenticationMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

extension LocalAuthenticationClient {
    static let mockAuthenticationSucceeded = Self(
        authenticate: { true }
    )
    
    static let mockAuthenticationFailed = Self(
        authenticate: { false }
    )
}
