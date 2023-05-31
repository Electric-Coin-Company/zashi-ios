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
    public var activeAppSessionFrom: () -> TimeInterval
    public var setActiveAppSessionFrom: (TimeInterval) async -> Void

    public var currency: () -> String
    public var setCurrenty: (String) async -> Void

    public var isFiatConverted: () -> Bool
    public var setIsFiatConverted: (Bool) async -> Void

    public var isRecoveryPhraseTestCompleted: () -> Bool
    public var setIsRecoveryPhraseTestCompleted: (Bool) async -> Void

    public var isSessionAutoshielded: () -> Bool
    public var setIsSessionAutoshielded: (Bool) async -> Void

    public var isUserOptedOutOfCrashReporting: () -> Bool
    public var setIsUserOptedOutOfCrashReporting: (Bool) async -> Void

    public var removeAll: () async -> Void
}
