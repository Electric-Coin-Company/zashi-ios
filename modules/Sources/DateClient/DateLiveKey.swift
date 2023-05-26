//
//  DateLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2023.
//

import Foundation
import ComposableArchitecture

extension DateClient: DependencyKey {
    public static let liveValue = Self(
        now: { Date.now }
    )
}
