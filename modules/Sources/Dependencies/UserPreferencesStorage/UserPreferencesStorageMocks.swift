//
//  UserPreferencesStorageMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation
import ComposableArchitecture

extension UserPreferencesStorageClient: TestDependencyKey {
    public static var testValue = {
        let mock = UserPreferencesStorage.mock

        return UserPreferencesStorageClient(
            activeAppSessionFrom: { mock.activeAppSessionFrom },
            setActiveAppSessionFrom: mock.setActiveAppSessionFrom(_:),
            currency: { mock.currency },
            setCurrenty: mock.setCurrency(_:),
            isFiatConverted: { mock.isFiatConverted },
            setIsFiatConverted: mock.setIsFiatConverted(_:),
            isRecoveryPhraseTestCompleted: {
                mock.isRecoveryPhraseTestCompleted
            },
            setIsRecoveryPhraseTestCompleted: mock.setIsRecoveryPhraseTestCompleted(_:),
            isSessionAutoshielded: { mock.isSessionAutoshielded },
            setIsSessionAutoshielded: mock.setIsSessionAutoshielded(_:),
            isUserOptedOutOfCrashReporting: {
                mock.isUserOptedOutOfCrashReporting
            },
            setIsUserOptedOutOfCrashReporting: mock.setIsUserOptedOutOfCrashReporting(_:),
            removeAll: mock.removeAll
        )
    }()
}

extension UserPreferencesStorage {
    public static let mock = UserPreferencesStorage(
        appSessionFrom: 1651039606.0,
        convertedCurrency: "USD",
        fiatConvertion: true,
        recoveryPhraseTestCompleted: false,
        sessionAutoshielded: true,
        userOptedOutOfCrashReporting: false,
        userDefaults: .noOp
    )
}
