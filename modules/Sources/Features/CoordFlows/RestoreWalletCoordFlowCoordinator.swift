//
//  RestoreWalletCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import ComposableArchitecture
import Generated

// Path

extension RestoreWalletCoordFlow {
    public func coordinatorReduce() -> Reduce<RestoreWalletCoordFlow.State, RestoreWalletCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Self

//            case .path(.element(id: _, action: .requestZec(.requestTapped))):
//                state.path.append(.requestZecSummary(state.requestZecState))
//                return .none

            default: return .none
            }
        }
    }
}
