//
//  DeeplinkInterface.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 11.11.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

extension DependencyValues {
    var deeplink: DeeplinkClient {
        get { self[DeeplinkClient.self] }
        set { self[DeeplinkClient.self] = newValue }
    }
}

struct DeeplinkClient {
    let resolveDeeplinkURL: (URL, DerivationToolClient) throws -> Deeplink.Destination
}
