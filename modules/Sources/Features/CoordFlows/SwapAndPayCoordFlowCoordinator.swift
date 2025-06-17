//
//  SwapAndPayCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-05-14.
//

import ComposableArchitecture
import Generated

// Path
import AddressBook
import Scan

extension SwapAndPayCoordFlow {
    public func coordinatorReduce() -> Reduce< SwapAndPayCoordFlow.State,  SwapAndPayCoordFlow.Action> {
        Reduce { state, action in
            switch action {

                // MARK: - Self

            case .swapAndPay(.scanTapped):
                var scanState = Scan.State.initial
                scanState.checkers = [.anyStringScanChecker]
                state.path.append(.scan(scanState))
                return .none

            default: return .none
            }
        }
    }
}
