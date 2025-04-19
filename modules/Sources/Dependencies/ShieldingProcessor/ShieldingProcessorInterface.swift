//
//  ShieldingProcessorInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-04-17.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit
import Combine

import Models

extension DependencyValues {
    public var shieldingProcessor: ShieldingProcessorClient {
        get { self[ShieldingProcessorClient.self] }
        set { self[ShieldingProcessorClient.self] = newValue }
    }
}

@DependencyClient
public struct ShieldingProcessorClient {
    public enum State: Equatable {
        case failed(ZcashError)
        case grpc
        case proposal(Proposal)
        case requested
        case succeeded
        case unknown
    }
    
    public let observe: () -> AnyPublisher<ShieldingProcessorClient.State, Never>
    public let shieldFunds: () -> Void
}
