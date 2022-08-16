//
//  WrappedUserDefaults.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.05.2022.
//

import Foundation

struct WrappedUserDefaults {
    let objectForKey: @Sendable (String) -> Any?
    let remove: @Sendable (String) async -> Void
    let setValue: @Sendable (Any?, String) async -> Void
    let synchronize: @Sendable () async -> Bool
}

extension WrappedUserDefaults {
    static func live(
        userDefaults: UserDefaults = .standard
    ) -> Self {
        Self(
            objectForKey: { userDefaults.object(forKey: $0) },
            remove: { userDefaults.removeObject(forKey: $0) },
            setValue: { userDefaults.set($0, forKey: $1) },
            synchronize: { userDefaults.synchronize() }
        )
    }
    
    static let mock = WrappedUserDefaults(
        objectForKey: { _ in },
        remove: { _ in },
        setValue: { _, _ in },
        synchronize: { true }
    )
}
