//
//  RestoreWalletStorageInterface.swift
//
//
//  Created by Lukáš Korba on 19.12.2023.
//

import Foundation
import ComposableArchitecture
import Combine

extension DependencyValues {
    public var restoreWalletStorage: RestoreWalletStorageClient {
        get { self[RestoreWalletStorageClient.self] }
        set { self[RestoreWalletStorageClient.self] = newValue }
    }
}

public struct RestoreWalletStorageClient {
    public var value: @Sendable () async -> AsyncStream<Bool>
    public var updateValue: @Sendable (Bool) async -> Void
}
