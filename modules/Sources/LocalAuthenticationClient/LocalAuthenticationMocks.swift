//
//  LocalAuthenticationMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

extension LocalAuthenticationClient {
    public static let mockAuthenticationSucceeded = Self(
        authenticate: { true }
    )
    
    public static let mockAuthenticationFailed = Self(
        authenticate: { false }
    )
}
