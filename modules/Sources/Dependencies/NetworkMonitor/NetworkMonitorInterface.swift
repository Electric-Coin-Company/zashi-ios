//
//  NetworkMonitorInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 04-07-2025.
//

import ComposableArchitecture
import Combine

extension DependencyValues {
    public var networkMonitor: NetworkMonitorClient {
        get { self[NetworkMonitorClient.self] }
        set { self[NetworkMonitorClient.self] = newValue }
    }
}

@DependencyClient
public struct NetworkMonitorClient {
    public let networkMonitorStream: () -> AnyPublisher<Bool, Never>
}
