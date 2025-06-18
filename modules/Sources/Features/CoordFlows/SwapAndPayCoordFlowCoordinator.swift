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

                // MARK: - Scan
                
            case .path(.element(id: _, action: .scan(.foundString(let address)))):
                let _ = state.path.removeLast()
                audioServices.systemSoundVibrate()
                state.swapAndPayState.address = address
                return .none

            case .path(.element(id: _, action: .scan(.cancelTapped))):
                let _ = state.path.popLast()
                return .none
                
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
