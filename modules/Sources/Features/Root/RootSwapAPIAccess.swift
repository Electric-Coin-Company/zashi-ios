//
//  RootSwapAPIAccess.swift
//  modules
//
//  Created by Lukáš Korba on 08.07.2025.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Generated
import Models

extension Root {
    public func swapAPIAccessReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .loadSwapAPIAccess:
                let swapAPIAccess = walletStorage.exportSwapAPIAccess()
                state.$swapAPIAccess.withLock { $0 = swapAPIAccess }
                return .none

            default: return .none
            }
        }
    }
}
