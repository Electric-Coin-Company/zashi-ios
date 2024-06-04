//
//  RestoreInfoStore.swift
//  Zashi
//
//  Created by Lukáš Korba on 06-03-2024
//

import ComposableArchitecture

import Generated

@Reducer
public struct RestoreInfo {
    @ObservableState
    public struct State: Equatable { }
    
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
