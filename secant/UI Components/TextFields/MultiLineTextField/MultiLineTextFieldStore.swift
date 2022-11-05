//
//  MultiLineTextFieldStore.swift
//  secant-testnet
//
//  Created by Lukáš Korba on 22.07.2022.
//

import Foundation
import ComposableArchitecture

typealias MultiLineTextFieldStore = Store<MultiLineTextFieldReducer.State, MultiLineTextFieldReducer.Action>

struct MultiLineTextFieldReducer: ReducerProtocol {
    struct State: Equatable {
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

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<MultiLineTextFieldReducer.State>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { _, action in
            switch action {
            case .binding(\.$text):
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

// MARK: - Store

extension MultiLineTextFieldStore {
    static let placeholder = MultiLineTextFieldStore(
        initialState: .placeholder,
        reducer: MultiLineTextFieldReducer()
    )
}

// MARK: - Placeholders

extension MultiLineTextFieldReducer.State {
    static let placeholder: MultiLineTextFieldReducer.State = {
        var state = MultiLineTextFieldReducer.State()
        state.text = "test"
        return state
    }()
}
