//
//  UserPreferencesStorageInterface.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/6/23.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    public var userStoredPreferences: UserPreferencesStorageClient {
        get { self[UserPreferencesStorageClient.self] }
        set { self[UserPreferencesStorageClient.self] = newValue }
    }
}

public struct UserPreferencesStorageClient {
    public var server: () -> UserPreferencesStorage.ServerConfig?
    public var setServer: (UserPreferencesStorage.ServerConfig) throws -> Void

    public var removeAll: () async -> Void
}
