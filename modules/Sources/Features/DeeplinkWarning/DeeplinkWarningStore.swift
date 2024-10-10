//
//  DeeplinkWarningStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-12-2024.
//

import ComposableArchitecture

import Generated
import Utils

@Reducer
public struct DeeplinkWarning {
    @ObservableState
    public struct State: Equatable {
        public init() { }
    }

    public enum Action: Equatable {
        case gotItTapped
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .gotItTapped:
                return .none
            }
        }
    }
}
