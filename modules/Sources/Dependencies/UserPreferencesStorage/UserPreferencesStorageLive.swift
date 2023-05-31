//
//  UserPreferencesStorageLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import ComposableArchitecture

extension UserPreferencesStorageClient: DependencyKey {
    public static var liveValue: UserPreferencesStorageClient = {
        let live = UserPreferencesStorage.live

        return UserPreferencesStorageClient(
            activeAppSessionFrom: { live.activeAppSessionFrom },
            setActiveAppSessionFrom: live.setActiveAppSessionFrom(_:),
            currency: { live.currency },
            setCurrenty: live.setCurrency(_:),
            isFiatConverted: { live.isFiatConverted },
            setIsFiatConverted: live.setIsFiatConverted(_:),
            isRecoveryPhraseTestCompleted: {
                live.isRecoveryPhraseTestCompleted
            },
            setIsRecoveryPhraseTestCompleted: live.setIsRecoveryPhraseTestCompleted(_:),
            isSessionAutoshielded: { live.isSessionAutoshielded },
            setIsSessionAutoshielded: live.setIsSessionAutoshielded(_:),
            isUserOptedOutOfCrashReporting: {
                live.isUserOptedOutOfCrashReporting
            },
            setIsUserOptedOutOfCrashReporting: live.setIsUserOptedOutOfCrashReporting(_:),
            removeAll: live.removeAll
        )
    }()
}

extension UserPreferencesStorage {
    public static let live = UserPreferencesStorage(
        appSessionFrom: Date().timeIntervalSince1970,
        convertedCurrency: "USD",
        fiatConvertion: true,
        recoveryPhraseTestCompleted: false,
        sessionAutoshielded: true,
        userOptedOutOfCrashReporting: false,
        userDefaults: .live()
    )
}
