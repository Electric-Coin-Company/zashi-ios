//
//  Near1ClickInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-15-2025.
//

import ComposableArchitecture
import Models

extension DependencyValues {
    public var near1Click: Near1ClickClient {
        get { self[Near1ClickClient.self] }
        set { self[Near1ClickClient.self] = newValue }
    }
}

@DependencyClient
public struct  Near1ClickClient {
    public let tokens: () async throws -> Set<ChainToken>
}
