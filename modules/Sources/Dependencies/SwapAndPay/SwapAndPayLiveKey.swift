//
//  SwapAndPayLiveKey.swift
//  Zashi
//
//  Created by Lukáš Korba on 05-15-2025.
//

import Foundation
import Network
import Combine
import ComposableArchitecture

extension SwapAndPayClient: DependencyKey {
    public static let liveValue = Self(
        swapAssets: {
            try await Near1Click.liveValue.swapAssets()
        },
        quote: {
            try await Near1Click.liveValue.quote()
        }
    )
}
