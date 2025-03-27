//
//  RestoreWalletCoordFlowStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 27-03-2025.
//

import SwiftUI
import ComposableArchitecture
import ZcashLightClientKit

// Path

@Reducer
public struct RestoreWalletCoordFlow {
    @Reducer
    public enum Path {
    }
    
    @ObservableState
    public struct State {
        public var path = StackState<Path.State>()
//        public var zecKeyboardState = ZecKeyboard.State.initial

        public init() { }
    }

    public enum Action {
        case path(StackActionOf<Path>)
//        case zecKeyboard(ZecKeyboard.Action)
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        coordinatorReduce()

//        Scope(state: \.zecKeyboardState, action: \.zecKeyboard) {
//            ZecKeyboard()
//        }

        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
