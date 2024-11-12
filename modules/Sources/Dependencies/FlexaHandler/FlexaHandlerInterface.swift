//
//  FlexaHandlerInterface.swift
//  Zashi
//
//  Created by Lukáš Korba on 03-09-2024
//

import Foundation
import ComposableArchitecture
import Combine
import Flexa
import ZcashLightClientKit

extension DependencyValues {
    public var flexaHandler: FlexaHandlerClient {
        get { self[FlexaHandlerClient.self] }
        set { self[FlexaHandlerClient.self] = newValue }
    }
}

@DependencyClient
public struct FlexaHandlerClient {
    public var prepare: @Sendable () -> Void
    public var open: @Sendable () -> Void
    public var onTransactionRequest: @Sendable () -> AnyPublisher<FlexaTransaction?, Never> = { Just(nil).eraseToAnyPublisher() }
    public var clearTransactionRequest: @Sendable () -> Void
    public var transactionSent: @Sendable (String, String) -> Void
    public var updateBalance: @Sendable (Zatoshi, Zatoshi?) -> Void
    public var flexaAlert: @Sendable (String, String) -> Void
    public var signOut: @Sendable () -> Void
}
