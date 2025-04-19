//
//  DeeplinkInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import DerivationTool

extension DependencyValues {
    public var deeplink: DeeplinkClient {
        get { self[DeeplinkClient.self] }
        set { self[DeeplinkClient.self] = newValue }
    }
}

@DependencyClient
public struct DeeplinkClient {
    public let resolveDeeplinkURL: (URL, NetworkType, DerivationToolClient) throws -> Deeplink.Destination
    
    public init(resolveDeeplinkURL: @escaping (URL, NetworkType, DerivationToolClient) throws -> Deeplink.Destination) {
        self.resolveDeeplinkURL = resolveDeeplinkURL
    }
}
