//
//  CheckCircleStore.swift
//  secant-testnet
//
//  Created by Michal Fousek on 26.09.2022.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias CheckCircleStore = Store<Bool, CheckCircleReducer.Action>
typealias CheckCircleViewStore = ViewStore<Bool, CheckCircleReducer.Action>

struct CheckCircleReducer: ReducerProtocol {
    typealias State = Bool
    
    enum Action: Equatable {
        case updateIsChecked
    }

    func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
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
            reducer: CheckCircleReducer()
        )
    }
}

// MARK: - ViewStore

extension CheckCircleViewStore {
    static let placeholder = CheckCircleStore(
        initialState: true,
        reducer: CheckCircleReducer()
    )
}
