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
            server: { live.server },
            setServer: live.setServer(_:),
            exchangeRate: { live.exchangeRate },
            setExchangeRate: live.setExchangeRate(_:),
            removeAll: live.removeAll
        )
    }()
}

extension UserPreferencesStorage {
    public static let live = UserPreferencesStorage(
        defaultExchangeRate: Data(),
        defaultServer: Data(),
        userDefaults: .live()
    )
}
