//
//  CheckCircleStore.swift
//  secant-testnet
//
//  Created by Michal Fousek on 26.09.2022.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias CheckCircleReducer = Reducer<Bool, CheckCircleAction, Void>
typealias CheckCircleStore = Store<Bool, CheckCircleAction>
typealias CheckCircleViewStore = ViewStore<Bool, CheckCircleAction>

// MARK: - Action

enum CheckCircleAction: Equatable {
    case updateIsChecked
}

// MARK: - Reducer

extension CheckCircleReducer {
    static let `default` = CheckCircleReducer { state, action, _ in
        switch action {
        case .updateIsChecked:
            state.toggle()
            return .none
        }
    }
}

// MARK: - Store

extension CheckCircleStore {
    static func mock(isChecked: Bool) -> CheckCircleStore {
        return CheckCircleStore(
            initialState: isChecked,
            reducer: .default,
            environment: Void()
        )
    }
}

// MARK: - ViewStore

extension CheckCircleViewStore {
    static let placeholder = CheckCircleStore(
        initialState: true,
        reducer: .default,
        environment: Void()
    )
}
