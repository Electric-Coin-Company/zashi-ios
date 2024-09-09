//
//  Welcome.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2022.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct Welcome {
    @ObservableState
    public struct State: Equatable { }
    
    public enum Action: Equatable {
        case debugMenuStartup
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { _, _ in return .none }
    }
}
