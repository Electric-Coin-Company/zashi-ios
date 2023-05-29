//
//  DeeplinkLiveKey.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import ComposableArchitecture

extension DeeplinkClient: DependencyKey {
    public static let liveValue = Self(
        resolveDeeplinkURL: { try Deeplink().resolveDeeplinkURL($0, networkType: $1, isValidZcashAddress: $2.isZcashAddress) }
    )
}
