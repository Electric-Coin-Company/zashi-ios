//
//  UserPreferencesStorageLive.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation

extension UserPreferencesStorage {
    static let live = UserPreferencesStorage(
        appSessionFrom: Date().timeIntervalSince1970,
        convertedCurrency: "USD",
        fiatConvertion: true,
        recoveryPhraseTestCompleted: false,
        sessionAutoshielded: true,
        userDefaults: .live()
    )
}
