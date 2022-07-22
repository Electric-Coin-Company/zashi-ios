//
//  MultiLineTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import Foundation
import ComposableArchitecture

typealias MultiLineTextFieldReducer = Reducer<MultiLineTextFieldState, MultiLineTextFieldAction, MultiLineTextFieldEnvironment>
typealias MultiLineTextFieldStore = Store<MultiLineTextFieldState, MultiLineTextFieldAction>
typealias MultiLineTextFieldViewStore = ViewStore<MultiLineTextFieldState, MultiLineTextFieldAction>

// MARK: - State

struct MultiLineTextFieldState: Equatable {
    /// default 0, no char limit
    var charLimit = 0
    @BindableState var text = ""
    
    var isCharLimited: Bool {
        charLimit > 0
    }
    
    var textLength: Int {
        text.count
    }
    
    var isValid: Bool {
        charLimit > 0
        ? textLength <= charLimit
        : true
    }
    
    var charLimitText: String {
        charLimit > 0
        ? isValid
        ? "\(textLength)/\(charLimit)"
        : "char limit exceeded \(textLength)/\(charLimit)"
        : ""
    }
}

// MARK: - Action

enum MultiLineTextFieldAction: Equatable, BindableAction {
    case binding(BindingAction<MultiLineTextFieldState>)
}

// MARK: - Environment

struct MultiLineTextFieldEnvironment { }

extension MultiLineTextFieldEnvironment {
    static let live = MultiLineTextFieldEnvironment()

    static let mock = MultiLineTextFieldEnvironment()
}

// MARK: - Reducer

extension MultiLineTextFieldReducer {
    static let `default` = MultiLineTextFieldReducer { _, action, _ in
        switch action {
        case .binding(\.$text):
            return .none
            
        case .binding:
            return .none
        }
    }
    .binding()
}

// MARK: - Store

extension MultiLineTextFieldStore {
    static let placeholder = MultiLineTextFieldStore(
        initialState: .placeholder,
        reducer: .default,
        environment: MultiLineTextFieldEnvironment()
    )
}

// MARK: - Placeholders

extension MultiLineTextFieldState {
    static let placeholder = MultiLineTextFieldState()
}
