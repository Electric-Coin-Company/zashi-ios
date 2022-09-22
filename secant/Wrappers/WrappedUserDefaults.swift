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

/// `UserDefaults` is thread-safe class. Because of that we can mark it as `Sendable` on our own. If it's marked as `Sendable` in `Foundation` in
/// future we can simply remove this line and be ok. This is probably simpliest and easiest way how to fix warnings about `UserDefaults` not being
/// sendable.
extension UserDefaults: @unchecked Sendable { }

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
