//
//  Welcome.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 04.04.2022.
//

import Foundation
import ComposableArchitecture

struct WelcomeState: Equatable {}

extension WelcomeState {
    static let placeholder = WelcomeState()
}

enum WelcomeAction: Equatable {
    case debugMenuStartup
}

typealias WelcomeReducer = Reducer<WelcomeState, WelcomeAction, Void>

extension WelcomeReducer {
    static let `default` = WelcomeReducer { _, _, _ in
        return .none
    }
}

typealias WelcomeStore = Store<WelcomeState, WelcomeAction>

extension WelcomeStore {
    static var demo = WelcomeStore(
        initialState: .placeholder,
        reducer: .default,
        environment: ()
    )
}
