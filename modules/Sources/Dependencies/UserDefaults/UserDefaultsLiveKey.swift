//
//  UserDefaultsLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 13.11.2022.
//

import Foundation
import ComposableArchitecture

extension UserDefaultsClient: DependencyKey {
    public static let liveValue = UserDefaultsClient.live()
    
    public static func live(userDefaults: UserDefaults = .standard) -> Self {
        Self(
            objectForKey: { userDefaults.object(forKey: $0) },
            remove: { userDefaults.removeObject(forKey: $0) },
            setValue: { userDefaults.set($0, forKey: $1) }
        )
    }
}
