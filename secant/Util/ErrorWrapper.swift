//
//  ErrorWrapper.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.03.2022.
//

import Foundation

/// Equatable wrapper for the errors, used in TCA's states
struct ErrorWrapper: Equatable {
    let error: Error
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        String(reflecting: lhs.error) == String(reflecting: rhs.error)
    }
}
