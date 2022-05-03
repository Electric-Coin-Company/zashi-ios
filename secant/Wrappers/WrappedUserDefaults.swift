//
//  WrappedUserDefaults.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 03.05.2022.
//

import Foundation
import ComposableArchitecture

struct WrappedUserDefaults {
    let objectForKey: (String) -> Any?
    let remove: (String) -> Effect<Never, Never>
    let setValue: (Any?, String) -> Effect<Never, Never>
    let synchronize: () -> Bool
}

extension WrappedUserDefaults {
    static func live(
        userDefaults: UserDefaults = .standard
    ) -> Self {
        Self(
            objectForKey: userDefaults.object(forKey:),
            remove: { key in
                .fireAndForget {
                    userDefaults.removeObject(forKey: key)
                }
            },
            setValue: { value, key in
                .fireAndForget {
                    userDefaults.set(value, forKey: key)
                }
            },
            synchronize: userDefaults.synchronize
        )
    }
    
    static let mock = WrappedUserDefaults(
        objectForKey: { _ in },
        remove: { _ in .none },
        setValue: { _, _ in .none },
        synchronize: { true }
    )
}
