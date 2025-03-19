//
//  RequestZecCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 2025-03-17.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

import ZecKeyboard

// Path
import RequestZec

@Reducer
public struct RequestZecCoordFlow {
    @Reducer
    public enum Path {
        case requestZec(RequestZec)
        case requestZecSummary(RequestZec)
    }
    
    @ObservableState
    public struct State {
        public var memo = ""
        public var path = StackState<Path.State>()
        public var uAddress: UnifiedAddress? = nil
        public var requestZecState = RequestZec.State.initial
        public var zecKeyboardState = ZecKeyboard.State.initial

        public init() { }
    }

    public enum Action {
        case path(StackActionOf<Path>)
        case zecKeyboard(ZecKeyboard.Action)
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

        Scope(state: \.zecKeyboardState, action: \.zecKeyboard) {
            ZecKeyboard()
        }

        Reduce { state, action in
            switch action {
            case .zecKeyboard:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
