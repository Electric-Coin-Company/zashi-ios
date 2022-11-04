//
//  Welcome.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2022.
//

import Foundation
import ComposableArchitecture

typealias WelcomeStore = Store<WelcomeReducer.State, WelcomeReducer.Action>

struct WelcomeReducer: ReducerProtocol {
    struct State: Equatable {}
    
    enum Action: Equatable {
        case debugMenuStartup
    }
    
    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        return .none
    }
}

// MARK: - Store

extension WelcomeStore {
    static var demo = WelcomeStore(
        initialState: .placeholder,
        reducer: WelcomeReducer()
    )
}

// MARK: - Placeholders

extension WelcomeReducer.State {
    static let placeholder = WelcomeReducer.State()
}
