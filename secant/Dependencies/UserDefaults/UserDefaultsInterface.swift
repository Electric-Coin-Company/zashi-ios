//
//  UserDefaultsInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 13.11.2022.
//

import Foundation
import ComposableArchitecture

/// `UserDefaults` is thread-safe class. Because of that we can mark it as `Sendable` on our own. If it's marked as `Sendable` in `Foundation` in
/// future we can simply remove this line and be ok. This is probably the simplest and easiest way how to fix warnings about `UserDefaults` not
/// being sendable.
extension UserDefaults: @unchecked Sendable { }

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

struct UserDefaultsClient {
    let objectForKey: @Sendable (String) -> Any?
    let remove: @Sendable (String) async -> Void
    let setValue: @Sendable (Any?, String) async -> Void
    let synchronize: @Sendable () async -> Bool
}
