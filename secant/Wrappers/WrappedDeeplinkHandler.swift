//
//  WrappedDeeplinkHandler.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 15.06.2022.
//

import Foundation
import ComposableArchitecture
import ZcashLightClientKit

struct WrappedDeeplinkHandler {
    let resolveDeeplinkURL: (URL, WrappedDerivationTool) throws -> DeeplinkHandler.Deeplink
}

extension WrappedDeeplinkHandler {
    static let live = WrappedDeeplinkHandler(
        resolveDeeplinkURL: { try DeeplinkHandler().resolveDeeplinkURL($0, derivationTool: $1) }
    )
}

private enum DeeplinkHandlerKey: DependencyKey {
    static let liveValue = WrappedDeeplinkHandler.live
    static let testValue = WrappedDeeplinkHandler.live
}

extension DependencyValues {
    var deeplinkHandler: WrappedDeeplinkHandler {
        get { self[DeeplinkHandlerKey.self] }
        set { self[DeeplinkHandlerKey.self] = newValue }
    }
}
