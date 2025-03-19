//
//  ScanCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-19.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import AudioServices

// Path
import Scan

@Reducer
public struct ScanCoordFlow {
    @ObservableState
    public struct State {
        public var scanState = Scan.State.initial
        public var sendCoordFlowBinding = false
        public var sendCoordFlowState = SendCoordFlow.State.initial

        public init() { }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<ScanCoordFlow.State>)
        case onAppear
        case scan(Scan.Action)
        case sendCoordFlow(SendCoordFlow.Action)
    }

    @Dependency(\.audioServices) var audioServices
    
    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        BindingReducer()

        Scope(state: \.scanState, action: \.scan) {
            Scan()
        }

        Scope(state: \.sendCoordFlowState, action: \.sendCoordFlow) {
            SendCoordFlow()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.scanState.checkers = [.zcashAddressScanChecker, .requestZecScanChecker]
                return .none
                
            case .binding:
                return .none
                
            case .scan:
                return .none

            case .sendCoordFlow:
                return .none
            }
        }
    }
}
