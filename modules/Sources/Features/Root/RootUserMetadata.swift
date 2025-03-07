//
//  RootUserMetadata.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-02-05.
//

import Combine
import ComposableArchitecture
import Foundation
import ZcashLightClientKit
import Generated
import Models

extension Root {
    public func userMetadataReduce() -> Reduce<Root.State, Root.Action> {
        Reduce { state, action in
            switch action {
            case .loadUserMetadata:
                guard let account = state.selectedWalletAccount?.account else {
                    return .none
                }
                try? userMetadataProvider.load(account)
                try? readTransactionsStorage.resetZashi()
                return .none

            default: return .none
            }
        }
    }
}
