//
//  RequestZecCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-17.
//

import ComposableArchitecture
import Generated

import RequestZec

extension RequestZecCoordFlow {
    public func coordinatorReduce() -> Reduce<RequestZecCoordFlow.State, RequestZecCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Request Zec

            case .path(.element(id: _, action: .requestZec(.requestTapped))):
                state.path.append(.requestZecSummary(state.requestZecState))
                return .none

            case .path(.element(id: _, action: .requestZec(.onDisappearMemoStep(let memoText)))):
                state.memo = memoText
                return .none

                // MARK: - Zec Keyboard

            case .zecKeyboard(.nextTapped):
                state.requestZecState.address = state.uAddress?.stringEncoded.redacted ?? "".redacted
                state.requestZecState.maxPrivacy = true
                state.requestZecState.memoState = .initial
                state.requestZecState.memoState.text = state.memo
                state.requestZecState.requestedZec = state.zecKeyboardState.amount
                state.path.append(.requestZec(state.requestZecState))
                return .none
                
            default: return .none
            }
        }
    }
}
