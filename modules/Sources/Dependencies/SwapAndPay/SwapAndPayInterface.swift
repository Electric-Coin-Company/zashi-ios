//
//  SwapAndPayInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-15-2025.
//

import ComposableArchitecture
import Models

extension DependencyValues {
    public var swapAndPay: SwapAndPayClient {
        get { self[SwapAndPayClient.self] }
        set { self[SwapAndPayClient.self] = newValue }
    }
}

@DependencyClient
public struct  SwapAndPayClient {
    public let swapAssets: () async throws -> IdentifiedArrayOf<SwapAsset>
    public let quote: () async throws -> Void
}
