//
//  UserPreferencesStorageMocks.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.11.2022.
//

import Foundation

extension UserPreferencesStorage {
    static let mock = UserPreferencesStorage(
        appSessionFrom: 1651039606.0,
        convertedCurrency: "USD",
        fiatConvertion: true,
        recoveryPhraseTestCompleted: false,
        sessionAutoshielded: true,
        userDefaults: .noOp
    )
}
