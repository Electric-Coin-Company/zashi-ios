//
//  ScanCoordFlowCoordinator.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-19.
//

import ComposableArchitecture
import Generated
import AudioServices

// Path
import Scan

extension ScanCoordFlow {
    public func coordinatorReduce() -> Reduce<ScanCoordFlow.State, ScanCoordFlow.Action> {
        Reduce { state, action in
            switch action {
                // MARK: - Scan
                
            case .scan(.foundAddress(let address)):
                audioServices.systemSoundVibrate()
                state.sendCoordFlowBinding = true
                return .send(.sendCoordFlow(.sendForm(.addressUpdated(address))))

            default: return .none
            }
        }
    }
}
