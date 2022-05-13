//
//  Welcome.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2022.
//

import Foundation
import ComposableArchitecture

typealias WelcomeReducer = Reducer<WelcomeState, WelcomeAction, WelcomeEnvironment>
typealias WelcomeStore = Store<WelcomeState, WelcomeAction>
typealias WelcomeViewStore = ViewStore<WelcomeState, WelcomeAction>

// MARK: - State

struct WelcomeState: Equatable {}

// MARK: - Action

enum WelcomeAction: Equatable {
    case debugMenuStartup
}

// MARK: - Environment

struct WelcomeEnvironment { }

// MARK: - Reducer

extension WelcomeReducer {
    static let `default` = WelcomeReducer { _, _, _ in
        return .none
    }
}

// MARK: - Store

extension WelcomeStore {
    static var demo = WelcomeStore(
        initialState: .placeholder,
        reducer: .default,
        environment: WelcomeEnvironment()
    )
}

// MARK: - Placeholders

extension WelcomeState {
    static let placeholder = WelcomeState()
}
