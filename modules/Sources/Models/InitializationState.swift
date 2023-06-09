//
//  InitializationState.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 30.03.2022.
//

import Foundation

public enum InitializationState: Equatable {
    case failed
    case initialized
    case keysMissing
    case filesMissing
    case uninitialized
}

public enum SDKInitializationError: Error {
    case failed
}
