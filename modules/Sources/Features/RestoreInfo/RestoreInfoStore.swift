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
    public struct State: Equatable {
        public var isAcknowledged = true
    }
    
    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<RestoreInfo.State>)
        case gotItTapped
    }

    public init() { }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .gotItTapped:
                return .none
            }
        }
    }
}
