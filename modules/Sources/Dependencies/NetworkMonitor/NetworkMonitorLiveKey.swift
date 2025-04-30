//
//  NetworkMonitorLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 04-07-2025.
//

import Foundation
import Network
import Combine
import ComposableArchitecture

extension NetworkMonitorClient: DependencyKey {
    public static let liveValue: NetworkMonitorClient = Self.live()
    
    public static func live() -> Self {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue.global(qos: .background)
        let subject = CurrentValueSubject<Bool, Never>(true)

        return NetworkMonitorClient(
            networkMonitorStream: {
                monitor.pathUpdateHandler = { subject.send($0.status == .satisfied) }
                monitor.start(queue: queue)

                return subject.eraseToAnyPublisher()
            }
        )
    }
}
