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
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

public struct UserDefaultsClient {
    public let objectForKey: (String) -> Any?
    public let remove: (String) -> Void
    public let setValue: (Any?, String) -> Void
    
    public init(objectForKey: @escaping (String) -> Any?, remove: @escaping (String) -> Void, setValue: @escaping (Any?, String) -> Void) {
        self.objectForKey = objectForKey
        self.remove = remove
        self.setValue = setValue
    }
}
