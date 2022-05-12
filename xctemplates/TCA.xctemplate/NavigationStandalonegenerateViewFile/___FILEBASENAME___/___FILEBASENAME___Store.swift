//___FILEHEADER___

import Foundation
import ComposableArchitecture
import SwiftUI

typealias ___VARIABLE_productName:identifier___Reducer = Reducer<___VARIABLE_productName:identifier___State, ___VARIABLE_productName:identifier___Action, ___VARIABLE_productName:identifier___Environment>
typealias ___VARIABLE_productName:identifier___Store = Store<___VARIABLE_productName:identifier___State, ___VARIABLE_productName:identifier___Action>
typealias ___VARIABLE_productName:identifier___ViewStore = ViewStore<___VARIABLE_productName:identifier___State, ___VARIABLE_productName:identifier___Action>

// MARK: - State

struct ___VARIABLE_productName:identifier___State: Equatable {
    enum Route: Equatable {
    }

    var route: Route?
}

// MARK: - Action

enum ___VARIABLE_productName:identifier___Action: Equatable {
    case updateRoute(___VARIABLE_productName:identifier___State.Route?)
}

// MARK: - Environment

struct ___VARIABLE_productName:identifier___Environment {
    
}

extension ___VARIABLE_productName:identifier___Environment {
    static let live = ___VARIABLE_productName:identifier___Environment(
    )

    static let mock = ___VARIABLE_productName:identifier___Environment(
    )
}

// MARK: - Reducer

extension ___VARIABLE_productName:identifier___Reducer {
    static let `default` = ___VARIABLE_productName:identifier___Reducer { state, action, environment in
        switch action {
        case .updateRoute(let route):
            state.route = route
            return .none
        }
        
        return .none
    }
}

// MARK: - Store

extension ___VARIABLE_productName:identifier___Store {

}

// MARK: - ViewStore

extension ___VARIABLE_productName:identifier___ViewStore {
    func bindingForRoute(_ route: ___VARIABLE_productName:identifier___State.Route) -> Binding<Bool> {
        self.binding(
            get: { $0.route == route },
            send: { isActive in
                return .updateRoute(isActive ? route : nil)
            }
        )
    }
}

// MARK: - Placeholders

extension ___VARIABLE_productName:identifier___State {
    static let placeholder = ___VARIABLE_productName:identifier___State(
    )
}

extension ___VARIABLE_productName:identifier___Store {
    static let placeholder = ___VARIABLE_productName:identifier___Store(
        initialState: .placeholder,
        reducer: .default,
        environment: ___VARIABLE_productName:identifier___Environment()
    )
}
