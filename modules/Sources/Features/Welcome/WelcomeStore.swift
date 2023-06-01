//
//  Welcome.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2022.
//

import Foundation
import ComposableArchitecture

public typealias WelcomeStore = Store<WelcomeReducer.State, WelcomeReducer.Action>

public struct WelcomeReducer: ReducerProtocol {
    public struct State: Equatable {}
    
    public enum Action: Equatable {
        case debugMenuStartup
    }
    
    public init() {}
    
    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        return .none
    }
}

// MARK: - Store

extension WelcomeStore {
    public static var demo = WelcomeStore(
        initialState: .placeholder,
        reducer: WelcomeReducer()
    )
}

// MARK: - Placeholders

extension WelcomeReducer.State {
    public static let placeholder = WelcomeReducer.State()
}
