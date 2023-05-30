//
//  LocalAuthenticationMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 12.11.2022.
//

extension LocalAuthenticationClient {
    public static let mockAuthenticationSucceeded = Self(
        authenticate: { _ in true }
    )
    
    public static let mockAuthenticationFailed = Self(
        authenticate: { _ in false }
    )
}
