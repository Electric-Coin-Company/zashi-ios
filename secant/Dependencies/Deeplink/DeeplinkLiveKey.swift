//
//  DeeplinkLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture

extension DeeplinkClient: DependencyKey {
    static let liveValue = Self(
        resolveDeeplinkURL: { try Deeplink().resolveDeeplinkURL($0, isValidZcashAddress: $1.isValidZcashAddress) }
    )
}
