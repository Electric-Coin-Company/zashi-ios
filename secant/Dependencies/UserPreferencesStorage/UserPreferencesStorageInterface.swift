//
//  UserPreferencesStorageInterface.swift
//  secant-testnet
//
//  Created by Francisco Gindre on 2/6/23.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var userStoredPreferences: UserPreferencesStorageClient {
        get { self [UserPreferencesStorageClient.self] }
        set { self[UserPreferencesStorageClient.self] = newValue }
    }
}

struct UserPreferencesStorageClient {
    var activeAppSessionFrom: () -> TimeInterval
    var setActiveAppSessionFrom: (TimeInterval) async -> Void

    var currency: () -> String
    var setCurrenty: (String) async -> Void

    var isFiatConverted: () -> Bool
    var setIsFiatConverted: (Bool) async -> Void

    var isRecoveryPhraseTestCompleted: () -> Bool
    var setIsRecoveryPhraseTestCompleted: (Bool) async -> Void

    var isSessionAutoshielded: () -> Bool
    var setIsSessionAutoshielded: (Bool) async -> Void

    var isUserOptedOutOfCrashReporting: () -> Bool
    var setIsUserOptedOutOfCrashReporting: (Bool) async -> Void

    var removeAll: () async -> Void
}
